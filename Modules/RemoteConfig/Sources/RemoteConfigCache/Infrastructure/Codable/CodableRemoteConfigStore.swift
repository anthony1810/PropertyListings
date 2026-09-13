import Foundation

public actor CodableRemoteConfigStore: RemoteConfigStore {
    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retrieve() async throws -> CachedRemoteConfig? {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return nil }
        let data = try Data(contentsOf: storeURL)
        let cache = try JSONDecoder().decode(CodableCache.self, from: data)
        return CachedRemoteConfig(
            configuration: Self.local(from: cache.configuration),
            timestamp: cache.timestamp
        )
    }

    public func insert(_ configuration: LocalRemoteConfig, timestamp: Date) async throws {
        let cache = CodableCache(
            configuration: Self.codable(from: configuration),
            timestamp: timestamp
        )
        try JSONEncoder().encode(cache).write(to: storeURL, options: .atomic)
    }
}

// MARK: - Codable to local

private extension CodableRemoteConfigStore {
    static func local(from codable: CodableConfiguration) -> LocalRemoteConfig {
        LocalRemoteConfig(
            listingsHost: codable.listingsHost,
            listingsPageSize: codable.listingsPageSize,
            listingsCacheMaxAgeInDays: codable.listingsCacheMaxAgeInDays,
            defaultLanguage: codable.defaultLanguage,
            supportedLanguages: codable.supportedLanguages,
            tabs: codable.tabs
        )
    }
}

// MARK: - Local to codable

private extension CodableRemoteConfigStore {
    static func codable(from local: LocalRemoteConfig) -> CodableConfiguration {
        CodableConfiguration(
            listingsHost: local.listingsHost,
            listingsPageSize: local.listingsPageSize,
            listingsCacheMaxAgeInDays: local.listingsCacheMaxAgeInDays,
            defaultLanguage: local.defaultLanguage,
            supportedLanguages: local.supportedLanguages,
            tabs: local.tabs
        )
    }
}

// MARK: - Codable representation

private extension CodableRemoteConfigStore {
    struct CodableCache: Codable {
        let configuration: CodableConfiguration
        let timestamp: Date
    }

    struct CodableConfiguration: Codable {
        let listingsHost: URL?
        let listingsPageSize: Int?
        let listingsCacheMaxAgeInDays: Int?
        let defaultLanguage: String?
        let supportedLanguages: [String]?
        let tabs: [String]?
    }
}
