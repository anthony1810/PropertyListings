import BookmarksPersistence
import Foundation
import Testing
import TestSupport

@Suite final class CodableBookmarkStoreTests {
    private let storeURL = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).store")

    // MARK: - Retrieve

    @Test func retrieve_deliversNoBookmarksOnEmptyStore() async throws {
        let sut = makeSUT()

        #expect(try await sut.retrieve() == [])
    }

    @Test func retrieve_hasNoSideEffectsOnEmptyStore() async throws {
        let sut = makeSUT()

        _ = try await sut.retrieve()

        #expect(try await sut.retrieve() == [])
    }

    @Test func retrieve_deliversInsertedBookmarksInInsertionOrder() async throws {
        let sut = makeSUT()
        let first = makeLocalBookmark(id: "a")
        let second = makeLocalBookmark(id: "b")

        try await sut.insert(first)
        try await sut.insert(second)

        #expect(try await sut.retrieve() == [first, second])
    }

    @Test func retrieve_deliversOptionalFieldsAndDecimalExactly() async throws {
        let sut = makeSUT()
        let bookmark = LocalBookmark(
            id: "1",
            title: "A title",
            priceAmount: Decimal(string: "999999999999999")!,
            priceCurrency: "CHF",
            street: nil,
            postalCode: nil,
            locality: "A locality",
            imageURL: nil,
            savedAt: Date()
        )

        try await sut.insert(bookmark)

        #expect(try await sut.retrieve() == [bookmark])
    }

    @Test func retrieve_failsOnInvalidData() async throws {
        let sut = makeSUT()
        try invalidJSON().write(to: storeURL)

        await #expect(throws: Error.self) {
            try await sut.retrieve()
        }
    }

    // MARK: - Insert

    @Test func insert_replacesABookmarkWithTheSameID() async throws {
        let sut = makeSUT()
        let earlier = makeLocalBookmark(id: "a", savedAt: Date())
        let later = makeLocalBookmark(id: "a", savedAt: Date().adding(seconds: 60))
        try await sut.insert(earlier)

        try await sut.insert(later)

        #expect(try await sut.retrieve() == [later])
    }

    @Test func insert_failsOnInvalidStoreURL() async {
        let sut = makeSUT(storeURL: URL(string: "invalid://store-url")!)

        await #expect(throws: Error.self) {
            try await sut.insert(makeLocalBookmark())
        }
    }

    // MARK: - Delete

    @Test func delete_hasNoSideEffectsOnEmptyStore() async throws {
        let sut = makeSUT()

        try await sut.delete(id: "missing")

        #expect(try await sut.retrieve() == [])
    }

    @Test func delete_removesOnlyTheBookmarkWithThatID() async throws {
        let sut = makeSUT()
        let kept = makeLocalBookmark(id: "a")
        try await sut.insert(kept)
        try await sut.insert(makeLocalBookmark(id: "b"))

        try await sut.delete(id: "b")

        #expect(try await sut.retrieve() == [kept])
    }

    // MARK: - Helpers

    private let leakTrackers = LockIsolated<[MemoryLeakTracker]>([])

    deinit {
        leakTrackers.value.forEach { $0.verify() }
        try? FileManager.default.removeItem(at: storeURL)
    }

    private func makeSUT(
        storeURL: URL? = nil,
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> CodableBookmarkStore {
        let sut = CodableBookmarkStore(storeURL: storeURL ?? self.storeURL)
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
