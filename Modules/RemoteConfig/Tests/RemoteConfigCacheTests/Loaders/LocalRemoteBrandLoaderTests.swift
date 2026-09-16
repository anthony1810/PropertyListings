import Foundation
import RemoteConfigCache
import RemoteConfigFeature
import Testing
import TestSupport

@Suite final class LocalRemoteBrandLoaderTests {
    @Test func init_doesNotMessageTheStore() {
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

        await #expect(throws: LocalRemoteBrandLoader.Error.cacheMiss) {
            try await sut.load()
        }
    }

    @Test func load_deliversTheCachedConfiguration_whenItIsWithinTheMaxAge() async throws {
        let now = Date()
        let pair = makeRemoteBrandPair()
        let (sut, store) = makeSUT(currentDate: now)
        store.completeRetrieval(
            with: CachedRemoteBrand(
                brand: pair.local,
                timestamp: now.adding(days: -maxAgeInDays).adding(seconds: 1)
            )
        )

        let brand = try await sut.load()

        #expect(brand == pair.model)
    }

    @Test func load_throwsCacheMiss_whenTheCacheReachedTheMaxAge() async {
        let now = Date()
        let (sut, store) = makeSUT(currentDate: now)
        store.completeRetrieval(
            with: CachedRemoteBrand(
                brand: makeRemoteBrandPair().local,
                timestamp: now.adding(days: -maxAgeInDays)
            )
        )

        await #expect(throws: LocalRemoteBrandLoader.Error.cacheMiss) {
            try await sut.load()
        }
    }

    // MARK: - Save

    @Test func save_insertsTheConfigurationWithTheCurrentDate() async throws {
        let now = Date()
        let pair = makeRemoteBrandPair()
        let (sut, store) = makeSUT(currentDate: now)

        try await sut.save(pair.model)

        #expect(store.receivedMessages == [.insert(pair.local, now)])
    }

    @Test func save_failsOnInsertionError() async {
        let (sut, store) = makeSUT()
        store.completeInsertion(with: anyNSError())

        await #expect(throws: Error.self) {
            try await sut.save(makeRemoteBrandPair().model)
        }
    }

    // MARK: - Helpers

    private let maxAgeInDays = 7
    private let leakTrackers = LockIsolated<[MemoryLeakTracker]>([])

    deinit {
        leakTrackers.value.forEach { $0.verify() }
    }

    private func makeSUT(
        currentDate: Date = Date(),
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> (sut: LocalRemoteBrandLoader, store: RemoteBrandStoreSpy) {
        let store = RemoteBrandStoreSpy()
        let sut = LocalRemoteBrandLoader(
            store: store,
            policy: RemoteConfigCachePolicy(maxAgeInDays: maxAgeInDays),
            currentDate: { currentDate }
        )
        trackForMemoryLeaks(store, sourceLocation: sourceLocation)
        return (sut, store)
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, sourceLocation: SourceLocation) {
        let tracker = MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
    }
}
