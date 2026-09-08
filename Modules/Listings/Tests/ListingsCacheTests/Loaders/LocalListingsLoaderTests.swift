import Foundation
import ListingsCache
import ListingsFeature
import Testing
import TestSupport

@Suite final class LocalListingsLoaderTests {
    @Test func init_doesNotMessageStore() {
        let (_, store) = makeSUT()

        #expect(store.receivedMessages == [])
    }

    // MARK: - Load

    @Test func load_requestsCacheRetrieval() async {
        let (sut, store) = makeSUT()
        store.completeRetrieval(with: nil)

        _ = try? await sut.load()

        #expect(store.receivedMessages == [.retrieve])
    }

    @Test func load_failsOnRetrievalError() async {
        let (sut, store) = makeSUT()
        store.completeRetrieval(with: anyNSError())

        await #expect(throws: Error.self) {
            try await sut.load()
        }
    }

    @Test func load_throwsCacheMissOnEmptyCache() async {
        let (sut, store) = makeSUT()
        store.completeRetrieval(with: nil)

        await #expect(throws: LocalListingsLoader.Error.cacheMiss) {
            try await sut.load()
        }
    }

    @Test func load_deliversMappedListingsOnNonExpiredCache() async throws {
        let now = Date()
        let nonExpired = now.minusCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: now)
        let listings = [makeListing(id: "a"), makeListing(id: "b", price: nil)]
        store.completeRetrieval(with: CachedListings(listings: listings.map(\.local), timestamp: nonExpired))

        let result = try await sut.load()

        #expect(result == listings.map(\.model))
    }

    @Test(arguments: [0.0, -1.0, -60 * 60 * 24] as [TimeInterval])
    func load_throwsCacheMissOnExpiredCache(offsetFromExpiry: TimeInterval) async {
        let now = Date()
        let expired = now.minusCacheMaxAge().adding(seconds: offsetFromExpiry)
        let (sut, store) = makeSUT(currentDate: now)
        store.completeRetrieval(with: CachedListings(listings: [makeLocalListing()], timestamp: expired))

        await #expect(throws: LocalListingsLoader.Error.cacheMiss) {
            try await sut.load()
        }
    }

    // MARK: - Save

    @Test func save_requestsDeletionThenInsertionOfMappedListingsWithTimestamp() async throws {
        let now = Date()
        let (sut, store) = makeSUT(currentDate: now)
        let listings = [makeListing(id: "a"), makeListing(id: "b", price: nil)]

        try await sut.save(listings.map(\.model))

        #expect(store.receivedMessages == [.deleteCachedListings, .insert(listings.map(\.local), now)])
    }

    @Test func save_doesNotInsertOnDeletionError() async {
        let (sut, store) = makeSUT()
        store.completeDeletion(with: anyNSError())

        _ = try? await sut.save([makeListing().model])

        #expect(store.receivedMessages == [.deleteCachedListings])
    }

    @Test func save_failsOnDeletionError() async {
        let (sut, store) = makeSUT()
        store.completeDeletion(with: anyNSError())

        await #expect(throws: Error.self) {
            try await sut.save([makeListing().model])
        }
    }

    @Test func save_failsOnInsertionError() async {
        let (sut, store) = makeSUT()
        store.completeInsertion(with: anyNSError())

        await #expect(throws: Error.self) {
            try await sut.save([makeListing().model])
        }
    }

    // MARK: - Helpers

    private let leakTrackers = LockIsolated<[MemoryLeakTracker]>([])

    deinit {
        leakTrackers.value.forEach { $0.verify() }
    }

    private func makeSUT(
        currentDate: Date = Date(),
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> (sut: LocalListingsLoader, store: ListingsStoreSpy) {
        let store = ListingsStoreSpy()
        let sut = LocalListingsLoader(store: store, currentDate: { currentDate })
        trackForMemoryLeaks(store, sourceLocation: sourceLocation)
        return (sut, store)
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, sourceLocation: SourceLocation) {
        let tracker = MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
    }
}

private extension Date {
    func minusCacheMaxAge() -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: -7, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
