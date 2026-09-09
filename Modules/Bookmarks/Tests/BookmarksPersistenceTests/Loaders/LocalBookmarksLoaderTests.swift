import BookmarksFeature
import BookmarksPersistence
import Foundation
import Testing
import TestSupport

@MainActor
@Suite final class LocalBookmarksLoaderTests {
    @Test func init_doesNotMessageStore() {
        let (_, store) = makeSUT()

        #expect(store.receivedMessages == [])
    }

    // MARK: - Load

    @Test func load_deliversMappedBookmarksNewestFirst() async throws {
        let (sut, store) = makeSUT()
        let older = makeBookmarkPair(id: "a", savedAt: now.adding(seconds: -60))
        let newer = makeBookmarkPair(id: "b", price: nil, savedAt: now)
        store.retrievalStub.complete(with: .success([older.local, newer.local]))

        let bookmarks = try await sut.load()

        #expect(bookmarks == [newer.model, older.model])
        #expect(store.receivedMessages == [.retrieve])
    }

    @Test func load_failsOnRetrievalError() async {
        let (sut, store) = makeSUT()
        store.retrievalStub.complete(with: .failure(anyNSError()))

        await #expect(throws: Error.self) {
            try await sut.load()
        }
    }

    // MARK: - Save

    @Test func save_insertsTheMappedBookmark() async throws {
        let (sut, store) = makeSUT()
        let bookmark = makeBookmarkPair(id: "a", price: nil)

        try await sut.save(bookmark.model)

        #expect(store.receivedMessages == [.insert(bookmark.local)])
    }

    @Test func save_failsOnInsertionError() async {
        let (sut, store) = makeSUT()
        store.insertionStub.complete(with: .failure(anyNSError()))

        await #expect(throws: Error.self) {
            try await sut.save(makeBookmarkPair().model)
        }
    }

    // MARK: - Remove

    @Test func remove_deletesByID() async throws {
        let (sut, store) = makeSUT()

        try await sut.remove(id: "a")

        #expect(store.receivedMessages == [.delete("a")])
    }

    @Test func remove_failsOnDeletionError() async {
        let (sut, store) = makeSUT()
        store.deletionStub.complete(with: .failure(anyNSError()))

        await #expect(throws: Error.self) {
            try await sut.remove(id: "a")
        }
    }

    // MARK: - Observe

    @Test func observe_replaysTheCurrentBookmarksOnSubscribe() async throws {
        await withMainSerialExecutor {
            let (sut, store) = makeSUT()
            let bookmark = makeBookmarkPair(id: "a")
            store.retrievalStub.complete(with: .success([bookmark.local]))
            let received = LockIsolated<[[Bookmark]]>([])

            let observation = Task {
                for await bookmarks in sut.observe() {
                    received.withValue { $0.append(bookmarks) }
                }
            }
            await Task.megaYield()

            #expect(received.value == [[bookmark.model]])
            await observation.cancelAndWait()
        }
    }

    @Test func observe_yieldsTheNewListAfterSave() async throws {
        try await withMainSerialExecutor {
            let (sut, store) = makeSUT()
            let bookmark = makeBookmarkPair(id: "a")
            let received = LockIsolated<[[Bookmark]]>([])
            let observation = Task {
                for await bookmarks in sut.observe() {
                    received.withValue { $0.append(bookmarks) }
                }
            }
            await Task.megaYield()
            store.retrievalStub.complete(with: .success([bookmark.local]))

            try await sut.save(bookmark.model)
            await Task.megaYield()

            #expect(received.value == [[], [bookmark.model]])
            await observation.cancelAndWait()
        }
    }

    @Test func observe_yieldsTheNewListAfterRemove() async throws {
        try await withMainSerialExecutor {
            let (sut, store) = makeSUT()
            let bookmark = makeBookmarkPair(id: "a")
            store.retrievalStub.complete(with: .success([bookmark.local]))
            let received = LockIsolated<[[Bookmark]]>([])
            let observation = Task {
                for await bookmarks in sut.observe() {
                    received.withValue { $0.append(bookmarks) }
                }
            }
            await Task.megaYield()
            store.retrievalStub.complete(with: .success([]))

            try await sut.remove(id: "a")
            await Task.megaYield()

            #expect(received.value == [[bookmark.model], []])
            await observation.cancelAndWait()
        }
    }

    @Test func observe_reachesEverySubscriber() async throws {
        try await withMainSerialExecutor {
            let (sut, store) = makeSUT()
            let bookmark = makeBookmarkPair(id: "a")
            let first = LockIsolated<[[Bookmark]]>([])
            let second = LockIsolated<[[Bookmark]]>([])
            let firstObservation = Task {
                for await bookmarks in sut.observe() {
                    first.withValue { $0.append(bookmarks) }
                }
            }
            let secondObservation = Task {
                for await bookmarks in sut.observe() {
                    second.withValue { $0.append(bookmarks) }
                }
            }
            await Task.megaYield()
            store.retrievalStub.complete(with: .success([bookmark.local]))

            try await sut.save(bookmark.model)
            await Task.megaYield()

            #expect(first.value == [[], [bookmark.model]])
            #expect(second.value == [[], [bookmark.model]])
            await firstObservation.cancelAndWait()
            await secondObservation.cancelAndWait()
        }
    }

    @Test func observe_stopsYieldingAfterCancellation() async throws {
        try await withMainSerialExecutor {
            let (sut, store) = makeSUT()
            let received = LockIsolated<[[Bookmark]]>([])
            let observation = Task {
                for await bookmarks in sut.observe() {
                    received.withValue { $0.append(bookmarks) }
                }
            }
            await Task.megaYield()
            await observation.cancelAndWait()
            store.retrievalStub.complete(with: .success([makeLocalBookmark()]))

            try await sut.save(makeBookmarkPair().model)
            await Task.megaYield()

            #expect(received.value == [[]])
        }
    }

    // MARK: - Helpers

    private let now = Date()
    private let leakTrackers = LockIsolated<[MemoryLeakTracker]>([])

    deinit {
        leakTrackers.value.forEach { $0.verify() }
    }

    private func makeSUT(
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> (sut: LocalBookmarksLoader, store: BookmarkStoreSpy) {
        let store = BookmarkStoreSpy()
        let sut = LocalBookmarksLoader(store: store)
        trackForMemoryLeaks(sut, sourceLocation: sourceLocation)
        trackForMemoryLeaks(store, sourceLocation: sourceLocation)
        return (sut, store)
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, sourceLocation: SourceLocation) {
        let tracker = MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
    }
}

private extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
