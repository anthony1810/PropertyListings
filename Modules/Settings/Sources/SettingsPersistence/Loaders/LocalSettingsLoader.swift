import Foundation
import SettingsFeature

public actor LocalSettingsLoader {
    private let store: SettingsStore
    private let defaultSettings: Settings
    private var subscribers: [UUID: AsyncStream<Settings>.Continuation] = [:]

    public init(store: SettingsStore, defaultSettings: Settings) {
        self.store = store
        self.defaultSettings = defaultSettings
    }

    public func load() async throws -> Settings {
        guard let local = try await store.retrieve() else { return defaultSettings }
        return Self.settings(from: local, fallback: defaultSettings)
    }

    public func save(_ settings: Settings) async throws {
        try await store.insert(Self.local(from: settings))
        await broadcast()
    }

    public nonisolated func observe() -> AsyncStream<Settings> {
        AsyncStream { continuation in
            let key = UUID()
            Task { await self.subscribe(key: key, continuation: continuation) }
            continuation.onTermination = { _ in
                Task { await self.unsubscribe(key: key) }
            }
        }
    }
}

// MARK: - Broadcast

private extension LocalSettingsLoader {
    func subscribe(key: UUID, continuation: AsyncStream<Settings>.Continuation) async {
        subscribers[key] = continuation
        continuation.yield(await currentSettings())
    }

    func unsubscribe(key: UUID) {
        subscribers[key] = nil
    }

    func broadcast() async {
        guard !subscribers.isEmpty else { return }
        let settings = await currentSettings()
        subscribers.values.forEach { $0.yield(settings) }
    }

    func currentSettings() async -> Settings {
        (try? await load()) ?? defaultSettings
    }
}

// MARK: - Local to domain

private extension LocalSettingsLoader {
    static func settings(from local: LocalSettings, fallback: Settings) -> Settings {
        Settings(
            appearance: Appearance(rawValue: local.appearance) ?? fallback.appearance,
            language: AppLanguage(rawValue: local.language) ?? fallback.language
        )
    }
}

// MARK: - Domain to local

private extension LocalSettingsLoader {
    static func local(from settings: Settings) -> LocalSettings {
        LocalSettings(appearance: settings.appearance.rawValue, language: settings.language.rawValue)
    }
}
