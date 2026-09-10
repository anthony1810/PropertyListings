import Foundation
import SettingsPersistence
import Testing
import TestSupport

@Suite final class CodableSettingsStoreTests {
    private let storeURL = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).store")

    // MARK: - Retrieve

    @Test func retrieve_deliversNothingOnEmptyStore() async throws {
        let sut = makeSUT()

        #expect(try await sut.retrieve() == nil)
    }

    @Test func retrieve_hasNoSideEffectsOnEmptyStore() async throws {
        let sut = makeSUT()

        _ = try await sut.retrieve()

        #expect(try await sut.retrieve() == nil)
    }

    @Test func retrieve_deliversTheInsertedSettings() async throws {
        let sut = makeSUT()
        let settings = makeLocalSettings(appearance: .dark, language: .french)

        try await sut.insert(settings)

        #expect(try await sut.retrieve() == settings)
    }

    @Test func retrieve_failsOnInvalidData() async throws {
        let sut = makeSUT()
        try invalidJSON().write(to: storeURL)

        await #expect(throws: Error.self) {
            try await sut.retrieve()
        }
    }

    // MARK: - Insert

    @Test func insert_replacesThePreviousSettings() async throws {
        let sut = makeSUT()
        let later = makeLocalSettings(appearance: .light, language: .italian)
        try await sut.insert(makeLocalSettings(appearance: .dark, language: .german))

        try await sut.insert(later)

        #expect(try await sut.retrieve() == later)
    }

    @Test func insert_failsOnInvalidStoreURL() async {
        let sut = makeSUT(storeURL: URL(string: "invalid://store-url")!)

        await #expect(throws: Error.self) {
            try await sut.insert(makeLocalSettings())
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
    ) -> CodableSettingsStore {
        let sut = CodableSettingsStore(storeURL: storeURL ?? self.storeURL)
        trackForMemoryLeaks(sut, sourceLocation: sourceLocation)
        return sut
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, sourceLocation: SourceLocation) {
        let tracker = MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
    }
}
