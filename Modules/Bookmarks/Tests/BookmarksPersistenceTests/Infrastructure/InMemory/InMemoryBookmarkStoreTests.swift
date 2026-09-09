import BookmarksPersistence
import Foundation
import Testing
import TestSupport

@Suite final class InMemoryBookmarkStoreTests {
    // MARK: - Retrieve

    @Test func retrieve_deliversNoBookmarksOnEmptyStore() async throws {
        let sut = makeSUT()

        #expect(try await sut.retrieve() == [])
    }

    @Test func retrieve_deliversTheInitialBookmarks() async throws {
        let initial = [makeLocalBookmark(id: "a")]
        let sut = makeSUT(bookmarks: initial)

        #expect(try await sut.retrieve() == initial)
    }

    @Test func retrieve_deliversInsertedBookmarksInInsertionOrder() async throws {
        let sut = makeSUT()
        let first = makeLocalBookmark(id: "a")
        let second = makeLocalBookmark(id: "b")

        try await sut.insert(first)
        try await sut.insert(second)

        #expect(try await sut.retrieve() == [first, second])
    }

    // MARK: - Insert

    @Test func insert_replacesABookmarkWithTheSameID() async throws {
        let sut = makeSUT()
        let later = makeLocalBookmark(id: "a", savedAt: Date().adding(seconds: 60))
        try await sut.insert(makeLocalBookmark(id: "a"))

        try await sut.insert(later)

        #expect(try await sut.retrieve() == [later])
    }

    // MARK: - Delete

    @Test func delete_removesOnlyTheBookmarkWithThatID() async throws {
        let kept = makeLocalBookmark(id: "a")
        let sut = makeSUT(bookmarks: [kept, makeLocalBookmark(id: "b")])

        try await sut.delete(id: "b")

        #expect(try await sut.retrieve() == [kept])
    }

    // MARK: - Helpers

    private let leakTrackers = LockIsolated<[MemoryLeakTracker]>([])

    deinit {
        leakTrackers.value.forEach { $0.verify() }
    }

    private func makeSUT(
        bookmarks: [LocalBookmark] = [],
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> InMemoryBookmarkStore {
        let sut = InMemoryBookmarkStore(bookmarks: bookmarks)
        trackForMemoryLeaks(sut, sourceLocation: sourceLocation)
        return sut
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
