import SettingsFeature
import SettingsPersistence
import SettingsTestSupport
import Testing
import TestSupport

@MainActor
@Suite final class LocalSettingsLoaderTests {
    @Test func init_doesNotMessageStore() {
        let (_, store) = makeSUT()

        #expect(store.receivedMessages == [])
    }

    // MARK: - Load

    @Test func load_deliversTheDefaultWhenTheStoreIsEmpty() async throws {
        let (sut, store) = makeSUT(defaultSettings: makeSettings(appearance: .dark, language: .italian))
        store.retrievalStub.complete(with: .success(nil))

        let settings = try await sut.load()

        #expect(settings == makeSettings(appearance: .dark, language: .italian))
        #expect(store.receivedMessages == [.retrieve])
    }

    @Test func load_deliversTheMappedSettings() async throws {
        let (sut, store) = makeSUT()
        let stored = makeSettingsPair(appearance: .light, language: .french)
        store.retrievalStub.complete(with: .success(stored.local))

        let settings = try await sut.load()

        #expect(settings == stored.model)
        #expect(store.receivedMessages == [.retrieve])
    }

    @Test func load_fallsBackToTheDefaultFieldOnAnUnknownRawValue() async throws {
        let (sut, store) = makeSUT(defaultSettings: makeSettings(appearance: .system, language: .german))
        store.retrievalStub.complete(with: .success(LocalSettings(appearance: "sepia", language: "rm")))

        let settings = try await sut.load()

        #expect(settings == makeSettings(appearance: .system, language: .german))
    }

    @Test func load_failsOnRetrievalError() async {
        let (sut, store) = makeSUT()
        store.retrievalStub.complete(with: .failure(anyNSError()))

        await #expect(throws: Error.self) {
            try await sut.load()
        }
    }

    // MARK: - Save

    @Test func save_insertsTheMappedSettings() async throws {
        let (sut, store) = makeSUT()
        let settings = makeSettingsPair(appearance: .dark, language: .french)

        try await sut.save(settings.model)

        #expect(store.receivedMessages == [.insert(settings.local)])
    }

    @Test func save_failsOnInsertionError() async {
        let (sut, store) = makeSUT()
        store.insertionStub.complete(with: .failure(anyNSError()))

        await #expect(throws: Error.self) {
            try await sut.save(makeSettingsPair().model)
        }
    }

    // MARK: - Helpers

    private let leakTrackers = LockIsolated<[MemoryLeakTracker]>([])

    deinit {
        leakTrackers.value.forEach { $0.verify() }
    }

    private func makeSUT(
        defaultSettings: Settings = makeSettings(),
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> (sut: LocalSettingsLoader, store: SettingsStoreSpy) {
        let store = SettingsStoreSpy()
        let sut = LocalSettingsLoader(store: store, defaultSettings: defaultSettings)
        trackForMemoryLeaks(sut, sourceLocation: sourceLocation)
        trackForMemoryLeaks(store, sourceLocation: sourceLocation)
        return (sut, store)
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, sourceLocation: SourceLocation) {
        let tracker = MemoryLeakTracker(instance: instance, sourceLocation: sourceLocation)
        leakTrackers.withValue { $0.append(tracker) }
    }
}
