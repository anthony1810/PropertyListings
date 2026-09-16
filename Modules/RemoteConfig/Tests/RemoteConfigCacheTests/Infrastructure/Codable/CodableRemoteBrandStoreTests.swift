import Foundation
import RemoteConfigCache
import Testing
import TestSupport

@Suite struct CodableRemoteBrandStoreTests {
    @Test func retrieve_deliversNothingOnAnEmptyStore() async throws {
        let sut = makeSUT()

        #expect(try await sut.retrieve() == nil)
    }

    @Test func retrieve_deliversTheInsertedConfigurationWithItsTimestamp() async throws {
        let now = Date()
        let local = makeRemoteBrandPair().local
        let sut = makeSUT()

        try await sut.insert(local, timestamp: now)

        #expect(
            try await sut.retrieve() == CachedRemoteBrand(brand: local, timestamp: now)
        )
    }

    @Test func insert_overwritesAPreviouslyInsertedConfiguration() async throws {
        let now = Date()
        let first = makeRemoteBrandPair(pageSize: 4).local
        let second = makeRemoteBrandPair(pageSize: 9).local
        let sut = makeSUT()

        try await sut.insert(first, timestamp: now.adding(days: -1))
        try await sut.insert(second, timestamp: now)

        #expect(
            try await sut.retrieve() == CachedRemoteBrand(brand: second, timestamp: now)
        )
    }

    // MARK: - Helpers

    private func makeSUT() -> CodableRemoteBrandStore {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "\(UUID().uuidString).json")
        return CodableRemoteBrandStore(storeURL: url)
    }
}
