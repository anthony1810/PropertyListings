import Foundation
import ListingsFeature
import ListingsPresentation
import ListingsTestSupport
import Testing
import TestSupport

@MainActor
@Suite final class ListingsViewModelTests {
    @Test func init_doesNotLoadAnything() {
        let (sut, spy) = makeSUT()

        #expect(spy.receivedMessages == [])
        #expect(sut.rows == [])
        #expect(sut.isLoading == false)
        #expect(sut.loadFailureMessage == nil)
    }

    // MARK: - Load

    @Test func load_deliversMappedRowsWithoutBookmarks() async {
        let (sut, spy) = makeSUT()
        let house = makeListing(id: "a", price: Price(amount: 9_999_999, currency: "CHF"))
        let flat = makeListing(id: "b", price: nil)
        spy.completeListings(with: .success([house, flat]))

        await sut.load()

        #expect(sut.rows == [
            ListingRowMapper.map(house, isBookmarked: false, locale: locale),
            ListingRowMapper.map(flat, isBookmarked: false, locale: locale),
        ])
        #expect(spy.receivedMessages == [.loadListings])
    }

    @Test func load_isLoadingWhileTheLoaderRuns() async {
        let (sut, spy) = makeSUT()
        let observed = LockIsolated<Bool?>(nil)
        spy.onNextLoadListings {
            let isLoading = sut.isLoading
            observed.setValue(isLoading)
        }
        spy.completeListings(with: .success([]))

        await sut.load()

        #expect(observed.value == true)
        #expect(sut.isLoading == false)
    }

    @Test func load_showsTheBlockingFailureWhenThereAreNoRowsYet() async {
        let (sut, spy) = makeSUT()
        spy.completeListings(with: .failure(anyNSError()))

        await sut.load()

        #expect(sut.rows == [])
        #expect(sut.loadFailureMessage == ListingsViewModel.Message.listingsFailed)
        #expect(spy.receivedMessages == [.loadListings])
    }

    @Test func load_keepsPreviousRowsAndNotifiesWhenARefreshFails() async {
        let (sut, spy) = makeSUT()
        spy.completeListings(with: .success([makeListing(id: "a")]))
        await sut.load()
        let previousRows = sut.rows
        spy.completeListings(with: .failure(anyNSError()))

        await sut.load()

        #expect(sut.rows == previousRows)
        #expect(sut.loadFailureMessage == nil)
        #expect(spy.receivedMessages == [.loadListings, .loadListings, .notify(ListingsViewModel.Message.listingsFailed)])
    }

    @Test func load_clearsTheBlockingFailureOnSuccess() async {
        let (sut, spy) = makeSUT()
        spy.completeListings(with: .failure(anyNSError()))
        await sut.load()
        spy.completeListings(with: .success([makeListing(id: "a")]))

        await sut.load()

        #expect(sut.loadFailureMessage == nil)
        #expect(sut.rows.map(\.id) == ["a"])
    }

    // MARK: - Helpers

    private let locale = Locale(identifier: "de_CH")
    private let leakTrackers = LockIsolated<[MemoryLeakTracker]>([])

    deinit {
        leakTrackers.value.forEach { $0.verify() }
    }

    private func makeSUT(
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> (sut: ListingsViewModel, spy: ListingsLoaderSpy) {
        let spy = ListingsLoaderSpy()
        let sut = ListingsViewModel(
            loadListings: spy.loadListings,
            notify: spy.notify,
            locale: locale
        )
        trackForMemoryLeaks(sut, sourceLocation: sourceLocation)
        trackForMemoryLeaks(spy, sourceLocation: sourceLocation)
        return (sut, spy)
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, sourceLocation: SourceLocation) {
        let tracker = MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
    }
}
