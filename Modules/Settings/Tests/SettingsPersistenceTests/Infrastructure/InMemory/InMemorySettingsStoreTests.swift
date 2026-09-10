import SettingsPersistence
import Testing
import TestSupport

@Suite final class InMemorySettingsStoreTests {
    // MARK: - Retrieve

    @Test func retrieve_deliversNothingOnEmptyStore() async throws {
        let sut = makeSUT()

        #expect(try await sut.retrieve() == nil)
    }

    @Test func retrieve_deliversTheInitialSettings() async throws {
        let initial = makeLocalSettings(appearance: .dark)
        let sut = makeSUT(settings: initial)

        #expect(try await sut.retrieve() == initial)
    }

    @Test func retrieve_deliversTheInsertedSettings() async throws {
        let sut = makeSUT()
        let settings = makeLocalSettings(language: .french)

        try await sut.insert(settings)

        #expect(try await sut.retrieve() == settings)
    }

    // MARK: - Insert

    @Test func insert_replacesThePreviousSettings() async throws {
        let sut = makeSUT()
        let later = makeLocalSettings(appearance: .light, language: .italian)
        try await sut.insert(makeLocalSettings(appearance: .dark, language: .german))

        try await sut.insert(later)

        #expect(try await sut.retrieve() == later)
    }

    // MARK: - Helpers

    private let leakTrackers = LockIsolated<[MemoryLeakTracker]>([])

    deinit {
        leakTrackers.value.forEach { $0.verify() }
    }

    private func makeSUT(
        settings: LocalSettings? = nil,
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> InMemorySettingsStore {
        let sut = InMemorySettingsStore(settings: settings)
        trackForMemoryLeaks(sut, sourceLocation: sourceLocation)
        return sut
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, sourceLocation: SourceLocation) {
        let tracker = MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
    }
}
