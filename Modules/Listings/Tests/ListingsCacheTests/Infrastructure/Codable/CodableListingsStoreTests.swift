import Foundation
import ListingsCache
import Testing
import TestSupport

@Suite final class CodableListingsStoreTests {
    private let storeURL = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).store")

    // MARK: - Retrieve

    @Test func retrieve_deliversNilOnEmptyCache() async throws {
        let sut = makeSUT()

        #expect(try await sut.retrieve() == nil)
    }

    @Test func retrieve_hasNoSideEffectsOnEmptyCache() async throws {
        let sut = makeSUT()

        _ = try await sut.retrieve()

        #expect(try await sut.retrieve() == nil)
    }

    @Test func retrieve_deliversInsertedValuesOnNonEmptyCache() async throws {
        let sut = makeSUT()
        let listings = [makeLocalListing(id: "a"), makeLocalListing(id: "b")]
        let timestamp = Date()

        try await sut.insert(listings, timestamp: timestamp)

        #expect(try await sut.retrieve() == CachedListings(listings: listings, timestamp: timestamp))
    }

    @Test func retrieve_hasNoSideEffectsOnNonEmptyCache() async throws {
        let sut = makeSUT()
        let cached = CachedListings(listings: [makeLocalListing()], timestamp: Date())
        try await sut.insert(cached.listings, timestamp: cached.timestamp)

        _ = try await sut.retrieve()

        #expect(try await sut.retrieve() == cached)
    }

    @Test func retrieve_deliversOptionalFieldsAndDecimalExactly() async throws {
        let sut = makeSUT()
        let listing = LocalListing(
            id: "1",
            title: "A title",
            priceAmount: Decimal(string: "999999999999999")!,
            priceCurrency: "CHF",
            street: nil,
            postalCode: nil,
            locality: "A locality",
            imageURL: nil
        )

        try await sut.insert([listing], timestamp: Date())

        #expect(try await sut.retrieve()?.listings == [listing])
    }

    @Test func retrieve_failsOnInvalidData() async throws {
        let sut = makeSUT()
        try invalidJSON().write(to: storeURL)

        await #expect(throws: Error.self) {
            try await sut.retrieve()
        }
    }

    // MARK: - Insert

    @Test func insert_overridesPreviouslyInsertedCache() async throws {
        let sut = makeSUT()
        try await sut.insert([makeLocalListing(id: "old")], timestamp: Date())
        let latest = CachedListings(listings: [makeLocalListing(id: "new")], timestamp: Date())

        try await sut.insert(latest.listings, timestamp: latest.timestamp)

        #expect(try await sut.retrieve() == latest)
    }

    @Test func insert_failsOnInvalidStoreURL() async {
        let sut = makeSUT(storeURL: URL(string: "invalid://store-url")!)

        await #expect(throws: Error.self) {
            try await sut.insert([makeLocalListing()], timestamp: Date())
        }
    }

    // MARK: - Delete

    @Test func delete_hasNoSideEffectsOnEmptyCache() async throws {
        let sut = makeSUT()

        try await sut.deleteCachedListings()

        #expect(try await sut.retrieve() == nil)
    }

    @Test func delete_emptiesPreviouslyInsertedCache() async throws {
        let sut = makeSUT()
        try await sut.insert([makeLocalListing()], timestamp: Date())

        try await sut.deleteCachedListings()

        #expect(try await sut.retrieve() == nil)
    }

    @Test func delete_failsOnNonDeletableStoreURL() async {
        let sut = makeSUT(storeURL: FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!)

        await #expect(throws: Error.self) {
            try await sut.deleteCachedListings()
        }
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
    ) -> CodableListingsStore {
        let sut = CodableListingsStore(storeURL: storeURL ?? self.storeURL)
        trackForMemoryLeaks(sut, sourceLocation: sourceLocation)
        return sut
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, sourceLocation: SourceLocation) {
        let tracker = MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
    }
}
