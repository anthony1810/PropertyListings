import Foundation

public actor CodableSettingsStore: SettingsStore {
    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retrieve() async throws -> LocalSettings? {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return nil }
        let data = try Data(contentsOf: storeURL)
        return Self.local(from: try JSONDecoder().decode(CodableSettings.self, from: data))
    }

    public func insert(_ settings: LocalSettings) async throws {
        try JSONEncoder().encode(Self.codable(from: settings)).write(to: storeURL, options: .atomic)
    }
}

// MARK: - Codable to local

private extension CodableSettingsStore {
    static func local(from codable: CodableSettings) -> LocalSettings {
        LocalSettings(appearance: codable.appearance, language: codable.language)
    }
}

// MARK: - Local to Codable

private extension CodableSettingsStore {
    static func codable(from local: LocalSettings) -> CodableSettings {
        CodableSettings(appearance: local.appearance, language: local.language)
    }
}

// MARK: - Codable representation

private extension CodableSettingsStore {
    struct CodableSettings: Codable {
        let appearance: String
        let language: String
    }
}
