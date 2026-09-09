import Foundation
import ListingsFeature
import ListingsPresentation
import ListingsTestSupport
import Testing
import TestSupport

@MainActor
@Suite final class ListingsViewModelTests {
    @Test func init_doesNotLoadAnything() {
        let (sut, spy, _) = makeSUT()

        #expect(spy.receivedMessages == [])
        #expect(sut.rows == [])
        #expect(sut.isLoading == false)
        #expect(sut.loadFailureMessage == nil)
    }

    // MARK: - Load

    @Test func load_deliversMappedRowsWithoutBookmarks() async {
        let (sut, spy, _) = makeSUT()
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
        let (sut, spy, _) = makeSUT()
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
        let (sut, spy, _) = makeSUT()
        spy.completeListings(with: .failure(anyNSError()))

        await sut.load()

        #expect(sut.rows == [])
        #expect(sut.loadFailureMessage == ListingsViewModel.Message.listingsFailed)
        #expect(spy.receivedMessages == [.loadListings])
    }

    @Test func load_keepsPreviousRowsAndNotifiesWhenARefreshFails() async {
        let (sut, spy, _) = makeSUT()
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
        let (sut, spy, _) = makeSUT()
        spy.completeListings(with: .failure(anyNSError()))
        await sut.load()
        spy.completeListings(with: .success([makeListing(id: "a")]))

        await sut.load()

        #expect(sut.loadFailureMessage == nil)
        #expect(sut.rows.map(\.id) == ["a"])
    }

    @Test func load_ignoresASecondCallWhileOneIsInFlight() async {
        await withMainSerialExecutor {
            let (sut, spy, _) = makeSUT()
            spy.completeListings(with: .success([makeListing(id: "a")]))
            let gate = spy.loadListingsStub.holdNext()
            let first = Task { await sut.load() }
            await Task.megaYield()

            await sut.load()

            gate.open()
            await first.value
            #expect(sut.rows.map(\.id) == ["a"])
            #expect(spy.receivedMessages == [.loadListings])
        }
    }

    // MARK: - Load more

    @Test func load_reportsWhetherMoreCanBeLoaded() async {
        let (sut, spy, _) = makeSUT()
        spy.completeListings(with: [makeListing(id: "a")], thenLoadMore: .success([makeListing(id: "b")]))

        await sut.load()

        #expect(sut.canLoadMore == true)
    }

    @Test func load_reportsNoMoreToLoadOnASinglePage() async {
        let (sut, spy, _) = makeSUT()
        spy.completeListings(with: .success([makeListing(id: "a")]))

        await sut.load()

        #expect(sut.canLoadMore == false)
    }

    @Test func loadMore_appendsTheNextPageAndReportsTheEnd() async {
        let (sut, spy, _) = makeSUT()
        spy.completeListings(with: [makeListing(id: "a")], thenLoadMore: .success([makeListing(id: "b")]))
        await sut.load()

        await sut.loadMore()

        #expect(sut.rows.map(\.id) == ["a", "b"])
        #expect(sut.canLoadMore == false)
        #expect(spy.receivedMessages == [.loadListings, .loadMore])
    }

    @Test func loadMore_doesNothingWhenThereIsNoNextPage() async {
        let (sut, spy, _) = makeSUT()
        spy.completeListings(with: .success([makeListing(id: "a")]))
        await sut.load()

        await sut.loadMore()

        #expect(sut.rows.map(\.id) == ["a"])
        #expect(spy.receivedMessages == [.loadListings])
    }

    @Test func loadMore_isLoadingMoreWhileTheLoaderRunsAndIgnoresASecondCall() async {
        await withMainSerialExecutor {
            let (sut, spy, _) = makeSUT()
            spy.completeListings(with: [makeListing(id: "a")], thenLoadMore: .success([makeListing(id: "b")]))
            await sut.load()
            let gate = spy.loadMoreStub.holdNext()
            let first = Task { await sut.loadMore() }
            await Task.megaYield()

            #expect(sut.isLoadingMore == true)
            await sut.loadMore()

            gate.open()
            await first.value
            #expect(sut.isLoadingMore == false)
            #expect(sut.rows.map(\.id) == ["a", "b"])
            #expect(spy.receivedMessages == [.loadListings, .loadMore])
        }
    }

    @Test func loadMore_keepsTheRowsAndNotifiesWhenItFails() async {
        let (sut, spy, _) = makeSUT()
        spy.completeListings(with: [makeListing(id: "a")], thenLoadMore: .failure(anyNSError()))
        await sut.load()

        await sut.loadMore()

        #expect(sut.rows.map(\.id) == ["a"])
        #expect(sut.canLoadMore == true)
        #expect(spy.receivedMessages == [.loadListings, .loadMore, .notify(ListingsViewModel.Message.listingsFailed)])
    }

    // MARK: - Observe bookmarks

    @Test func observeBookmarks_subscribesToBookmarkedIDs() async {
        await withMainSerialExecutor {
            let (sut, spy, _) = makeSUT()

            let observation = Task { await sut.observeBookmarks() }
            await Task.megaYield()

            #expect(spy.receivedMessages == [.observeBookmarkedIDs])
            await observation.cancelAndWait()
        }
    }

    @Test func observeBookmarks_flagsRowsAsTheStreamEmits() async {
        await withMainSerialExecutor {
            let (sut, spy, _) = makeSUT()
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
            let (sut, spy, _) = makeSUT()
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

    @Test func toggleBookmark_flagsTheRowAtOnceAndSavesTheListingAfterTheDebounce() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT()
            let listing = makeListing(id: "a")
            spy.completeListings(with: .success([listing]))
            await sut.load()

            sut.toggleBookmark(id: "a")

            #expect(sut.rows.map(\.isBookmarked) == [true])
            #expect(spy.receivedMessages == [.loadListings])
            await clock.advance(by: ListingsViewModel.toggleDebounce)
            await Task.megaYield()
            #expect(spy.receivedMessages == [.loadListings, .saveBookmark(listing)])
        }
    }

    @Test func toggleBookmark_unflagsTheRowAtOnceAndRemovesTheBookmarkAfterTheDebounce() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT()
            spy.completeListings(with: .success([makeListing(id: "a")]))
            await sut.load()
            let observation = Task { await sut.observeBookmarks() }
            await Task.megaYield()
            spy.emitBookmarkedIDs(["a"])
            await Task.megaYield()

            sut.toggleBookmark(id: "a")

            #expect(sut.rows.map(\.isBookmarked) == [false])
            await clock.advance(by: ListingsViewModel.toggleDebounce)
            await Task.megaYield()
            #expect(spy.receivedMessages == [.loadListings, .observeBookmarkedIDs, .removeBookmark("a")])
            await observation.cancelAndWait()
        }
    }

    @Test func toggleBookmark_ignoresAnUnknownID() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT()
            spy.completeListings(with: .success([makeListing(id: "a")]))
            await sut.load()

            sut.toggleBookmark(id: "missing")

            await clock.advance(by: ListingsViewModel.toggleDebounce)
            await Task.megaYield()
            #expect(sut.rows.map(\.isBookmarked) == [false])
            #expect(spy.receivedMessages == [.loadListings])
        }
    }

    @Test func toggleBookmark_persistsNothingWhenTapsWithinTheDebounceCancelOut() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT()
            spy.completeListings(with: .success([makeListing(id: "a")]))
            await sut.load()

            sut.toggleBookmark(id: "a")
            sut.toggleBookmark(id: "a")

            #expect(sut.rows.map(\.isBookmarked) == [false])
            await clock.advance(by: ListingsViewModel.toggleDebounce)
            await Task.megaYield()
            #expect(spy.receivedMessages == [.loadListings])
        }
    }

    @Test func toggleBookmark_restartsTheDebounceOnEveryTapAndPersistsTheFinalStateOnce() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT()
            let listing = makeListing(id: "a")
            spy.completeListings(with: .success([listing]))
            await sut.load()
            let halfway = ListingsViewModel.toggleDebounce / 2

            sut.toggleBookmark(id: "a")
            await clock.advance(by: halfway)
            sut.toggleBookmark(id: "a")
            await clock.advance(by: halfway)
            sut.toggleBookmark(id: "a")
            await clock.advance(by: halfway)
            await Task.megaYield()

            #expect(sut.rows.map(\.isBookmarked) == [true])
            #expect(spy.receivedMessages == [.loadListings])
            await clock.advance(by: halfway)
            await Task.megaYield()
            #expect(spy.receivedMessages == [.loadListings, .saveBookmark(listing)])
        }
    }

    @Test func toggleBookmark_persistsRowsIndependently() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT()
            let first = makeListing(id: "a")
            let second = makeListing(id: "b")
            spy.completeListings(with: .success([first, second]))
            await sut.load()

            sut.toggleBookmark(id: "a")
            sut.toggleBookmark(id: "b")

            await clock.advance(by: ListingsViewModel.toggleDebounce)
            await Task.megaYield()
            #expect(sut.rows.map(\.isBookmarked) == [true, true])
            #expect(spy.receivedMessages == [.loadListings, .saveBookmark(first), .saveBookmark(second)])
        }
    }

    @Test func toggleBookmark_revertsTheRowAndNotifiesWhenSavingFails() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT()
            let listing = makeListing(id: "a")
            spy.completeListings(with: .success([listing]))
            await sut.load()
            spy.saveBookmarkStub.complete(with: .failure(anyNSError()))

            sut.toggleBookmark(id: "a")

            await clock.advance(by: ListingsViewModel.toggleDebounce)
            await Task.megaYield()
            #expect(sut.rows.map(\.isBookmarked) == [false])
            #expect(spy.receivedMessages == [
                .loadListings,
                .saveBookmark(listing),
                .notify(ListingsViewModel.Message.bookmarkNotSaved),
            ])
        }
    }

    @Test func toggleBookmark_revertsTheRowAndNotifiesWhenRemovingFails() async {
        await withMainSerialExecutor {
            let (sut, spy, clock) = makeSUT()
            spy.completeListings(with: .success([makeListing(id: "a")]))
            await sut.load()
            let observation = Task { await sut.observeBookmarks() }
            await Task.megaYield()
            spy.emitBookmarkedIDs(["a"])
            await Task.megaYield()
            spy.removeBookmarkStub.complete(with: .failure(anyNSError()))

            sut.toggleBookmark(id: "a")

            await clock.advance(by: ListingsViewModel.toggleDebounce)
            await Task.megaYield()
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
    ) -> (sut: ListingsViewModel, spy: ListingsLoaderSpy, clock: TestClock<Duration>) {
        let spy = ListingsLoaderSpy()
        let clock = TestClock()
        let sut = ListingsViewModel(
            loadListings: spy.loadListings,
            observeBookmarkedIDs: spy.observeBookmarkedIDs,
            saveBookmark: spy.saveBookmark,
            removeBookmark: spy.removeBookmark,
            notify: spy.notify,
            locale: locale,
            clock: clock
        )
        trackForMemoryLeaks(sut, sourceLocation: sourceLocation)
        trackForMemoryLeaks(spy, sourceLocation: sourceLocation)
        return (sut, spy, clock)
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, sourceLocation: SourceLocation) {
        let tracker = MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
    }
}
