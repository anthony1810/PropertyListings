import Foundation
import RemoteConfigCache
import Testing
import TestSupport

@Suite struct CodableRemoteConfigStoreTests {
    @Test func retrieve_deliversNothingOnAnEmptyStore() async throws {
        let sut = makeSUT()

        #expect(try await sut.retrieve() == nil)
    }

    @Test func retrieve_deliversTheInsertedConfigurationWithItsTimestamp() async throws {
        let now = Date()
        let local = makeRemoteConfigPair().local
        let sut = makeSUT()

        try await sut.insert(local, timestamp: now)

        #expect(
            try await sut.retrieve() == CachedRemoteConfig(configuration: local, timestamp: now)
        )
    }

    @Test func insert_overwritesAPreviouslyInsertedConfiguration() async throws {
        let now = Date()
        let first = makeRemoteConfigPair(pageSize: 4).local
        let second = makeRemoteConfigPair(pageSize: 9).local
        let sut = makeSUT()

        try await sut.insert(first, timestamp: now.adding(days: -1))
        try await sut.insert(second, timestamp: now)

        #expect(
            try await sut.retrieve() == CachedRemoteConfig(configuration: second, timestamp: now)
        )
    }

    // MARK: - Helpers

    private func makeSUT() -> CodableRemoteConfigStore {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "\(UUID().uuidString).json")
        return CodableRemoteConfigStore(storeURL: url)
    }
}
