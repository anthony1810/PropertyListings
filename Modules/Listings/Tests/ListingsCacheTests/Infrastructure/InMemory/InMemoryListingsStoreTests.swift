import Foundation
import ListingsCache
import Testing
import TestSupport

@Suite final class InMemoryListingsStoreTests {
    // MARK: - Retrieve

    @Test func retrieve_deliversNilOnEmptyCache() async throws {
        let sut = makeSUT()

        #expect(try await sut.retrieve() == nil)
    }

    @Test func retrieve_deliversInitialCache() async throws {
        let cached = CachedListings(listings: [makeLocalListing()], timestamp: Date())
        let sut = makeSUT(cache: cached)

        #expect(try await sut.retrieve() == cached)
    }

    @Test func retrieve_deliversInsertedValuesOnNonEmptyCache() async throws {
        let sut = makeSUT()
        let cached = CachedListings(listings: [makeLocalListing(id: "a"), makeLocalListing(id: "b")], timestamp: Date())

        try await sut.insert(cached.listings, timestamp: cached.timestamp)

        #expect(try await sut.retrieve() == cached)
    }

    // MARK: - Insert

    @Test func insert_overridesPreviouslyInsertedCache() async throws {
        let sut = makeSUT()
        try await sut.insert([makeLocalListing(id: "old")], timestamp: Date())
        let latest = CachedListings(listings: [makeLocalListing(id: "new")], timestamp: Date())

        try await sut.insert(latest.listings, timestamp: latest.timestamp)

        #expect(try await sut.retrieve() == latest)
    }

    // MARK: - Delete

    @Test func delete_emptiesPreviouslyInsertedCache() async throws {
        let sut = makeSUT()
        try await sut.insert([makeLocalListing()], timestamp: Date())

        try await sut.deleteCachedListings()

        #expect(try await sut.retrieve() == nil)
    }

    // MARK: - Helpers

    private let leakTrackers = LockIsolated<[MemoryLeakTracker]>([])

    deinit {
        leakTrackers.value.forEach { $0.verify() }
    }

    private func makeSUT(
        cache: CachedListings? = nil,
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> InMemoryListingsStore {
        let sut = InMemoryListingsStore(cache: cache)
        trackForMemoryLeaks(sut, sourceLocation: sourceLocation)
        return sut
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, sourceLocation: SourceLocation) {
        let tracker = MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
    }
}
