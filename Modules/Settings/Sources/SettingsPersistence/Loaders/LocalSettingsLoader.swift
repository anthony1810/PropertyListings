import SettingsFeature

public actor LocalSettingsLoader {
    private let store: SettingsStore
    private let defaultSettings: Settings

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
