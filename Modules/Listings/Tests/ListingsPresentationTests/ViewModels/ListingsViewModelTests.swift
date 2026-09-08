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

    // MARK: - Observe bookmarks

    @Test func observeBookmarks_subscribesToBookmarkedIDs() async {
        await withMainSerialExecutor {
            let (sut, spy) = makeSUT()

            let observation = Task { await sut.observeBookmarks() }
            await Task.megaYield()

            #expect(spy.receivedMessages == [.observeBookmarkedIDs])
            await observation.cancelAndWait()
        }
    }

    @Test func observeBookmarks_flagsRowsAsTheStreamEmits() async {
        await withMainSerialExecutor {
            let (sut, spy) = makeSUT()
            spy.completeListings(with: .success([makeListing(id: "a"), makeListing(id: "b")]))
            await sut.load()
            let observation = Task { await sut.observeBookmarks() }
            await Task.megaYield()

            spy.emitBookmarkedIDs(["b"])
            await Task.megaYield()
            #expect(sut.rows.map(\.isBookmarked) == [false, true])

            spy.emitBookmarkedIDs([])
            await Task.megaYield()
            #expect(sut.rows.map(\.isBookmarked) == [false, false])

            await observation.cancelAndWait()
        }
    }

    @Test func observeBookmarks_flagsRowsLoadedAfterTheStreamEmitted() async {
        await withMainSerialExecutor {
            let (sut, spy) = makeSUT()
            let observation = Task { await sut.observeBookmarks() }
            await Task.megaYield()
            spy.emitBookmarkedIDs(["a"])
            await Task.megaYield()
            spy.completeListings(with: .success([makeListing(id: "a"), makeListing(id: "b")]))

            await sut.load()

            #expect(sut.rows.map(\.isBookmarked) == [true, false])
            await observation.cancelAndWait()
        }
    }

    // MARK: - Toggle bookmark

    @Test func toggleBookmark_flagsTheRowAndSavesTheListingWhenNotBookmarked() async {
        let (sut, spy) = makeSUT()
        let listing = makeListing(id: "a")
        spy.completeListings(with: .success([listing]))
        await sut.load()

        await sut.toggleBookmark(id: "a")

        #expect(sut.rows.map(\.isBookmarked) == [true])
        #expect(spy.receivedMessages == [.loadListings, .saveBookmark(listing)])
    }

    @Test func toggleBookmark_unflagsTheRowAndRemovesTheBookmarkWhenBookmarked() async {
        await withMainSerialExecutor {
            let (sut, spy) = makeSUT()
            spy.completeListings(with: .success([makeListing(id: "a")]))
            await sut.load()
            let observation = Task { await sut.observeBookmarks() }
            await Task.megaYield()
            spy.emitBookmarkedIDs(["a"])
            await Task.megaYield()

            await sut.toggleBookmark(id: "a")

            #expect(sut.rows.map(\.isBookmarked) == [false])
            #expect(spy.receivedMessages == [.loadListings, .observeBookmarkedIDs, .removeBookmark("a")])
            await observation.cancelAndWait()
        }
    }

    @Test func toggleBookmark_ignoresAnUnknownID() async {
        let (sut, spy) = makeSUT()
        spy.completeListings(with: .success([makeListing(id: "a")]))
        await sut.load()

        await sut.toggleBookmark(id: "missing")

        #expect(sut.rows.map(\.isBookmarked) == [false])
        #expect(spy.receivedMessages == [.loadListings])
    }

    @Test func toggleBookmark_revertsTheRowAndNotifiesWhenSavingFails() async {
        let (sut, spy) = makeSUT()
        let listing = makeListing(id: "a")
        spy.completeListings(with: .success([listing]))
        await sut.load()
        spy.completeSaveBookmark(with: anyNSError())

        await sut.toggleBookmark(id: "a")

        #expect(sut.rows.map(\.isBookmarked) == [false])
        #expect(spy.receivedMessages == [
            .loadListings,
            .saveBookmark(listing),
            .notify(ListingsViewModel.Message.bookmarkNotSaved),
        ])
    }

    @Test func toggleBookmark_revertsTheRowAndNotifiesWhenRemovingFails() async {
        await withMainSerialExecutor {
            let (sut, spy) = makeSUT()
            spy.completeListings(with: .success([makeListing(id: "a")]))
            await sut.load()
            let observation = Task { await sut.observeBookmarks() }
            await Task.megaYield()
            spy.emitBookmarkedIDs(["a"])
            await Task.megaYield()
            spy.completeRemoveBookmark(with: anyNSError())

            await sut.toggleBookmark(id: "a")

            #expect(sut.rows.map(\.isBookmarked) == [true])
            #expect(spy.receivedMessages == [
                .loadListings,
                .observeBookmarkedIDs,
                .removeBookmark("a"),
                .notify(ListingsViewModel.Message.bookmarkNotSaved),
            ])
            await observation.cancelAndWait()
        }
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
            observeBookmarkedIDs: spy.observeBookmarkedIDs,
            saveBookmark: spy.saveBookmark,
            removeBookmark: spy.removeBookmark,
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
