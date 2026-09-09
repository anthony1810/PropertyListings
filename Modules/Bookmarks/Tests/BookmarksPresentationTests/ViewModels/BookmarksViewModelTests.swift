import BookmarksFeature
import BookmarksPresentation
import BookmarksTestSupport
import Foundation
import Testing
import TestSupport

@MainActor
@Suite final class BookmarksViewModelTests {
    @Test func init_doesNotObserveAnything() {
        let (sut, spy) = makeSUT()

        #expect(spy.receivedMessages == [])
        #expect(sut.rows == [])
    }

    // MARK: - Observe

    @Test func observe_subscribesToBookmarks() async {
        await withMainSerialExecutor {
            let (sut, spy) = makeSUT()

            let observation = Task { await sut.observe() }
            await Task.megaYield()

            #expect(spy.receivedMessages == [.observeBookmarks])
            await observation.cancelAndWait()
        }
    }

    @Test func observe_deliversMappedRowsAsTheStreamEmits() async {
        await withMainSerialExecutor {
            let (sut, spy) = makeSUT()
            let newer = makeBookmark(id: "a")
            let older = makeBookmark(id: "b", price: nil)
            let observation = Task { await sut.observe() }
            await Task.megaYield()

            spy.emitBookmarks([newer, older])
            await Task.megaYield()

            #expect(sut.rows == [
                BookmarkRowMapper.map(newer, locale: locale),
                BookmarkRowMapper.map(older, locale: locale),
            ])
            await observation.cancelAndWait()
        }
    }

    @Test func observe_replacesTheRowsOnEveryEmission() async {
        await withMainSerialExecutor {
            let (sut, spy) = makeSUT()
            let observation = Task { await sut.observe() }
            await Task.megaYield()
            spy.emitBookmarks([makeBookmark(id: "a"), makeBookmark(id: "b")])
            await Task.megaYield()

            spy.emitBookmarks([makeBookmark(id: "b")])
            await Task.megaYield()

            #expect(sut.rows.map(\.id) == ["b"])
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
    ) -> (sut: BookmarksViewModel, spy: BookmarksLoaderSpy) {
        let spy = BookmarksLoaderSpy()
        let sut = BookmarksViewModel(
            observeBookmarks: spy.observeBookmarks,
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
