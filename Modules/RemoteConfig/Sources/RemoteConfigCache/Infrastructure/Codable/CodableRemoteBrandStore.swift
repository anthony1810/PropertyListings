import Foundation

public actor CodableRemoteBrandStore: RemoteBrandStore {
    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retrieve() async throws -> CachedRemoteBrand? {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return nil }
        let data = try Data(contentsOf: storeURL)
        let cache = try JSONDecoder().decode(CodableCache.self, from: data)
        return CachedRemoteBrand(brand: Self.local(from: cache.brand), timestamp: cache.timestamp)
    }

    public func insert(_ brand: LocalRemoteBrand, timestamp: Date) async throws {
        let cache = CodableCache(brand: Self.codable(from: brand), timestamp: timestamp)
        try JSONEncoder().encode(cache).write(to: storeURL, options: .atomic)
    }
}

// MARK: - Codable to local

private extension CodableRemoteBrandStore {
    static func local(from codable: CodableBrand) -> LocalRemoteBrand {
        LocalRemoteBrand(
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

private extension CodableRemoteBrandStore {
    static func codable(from local: LocalRemoteBrand) -> CodableBrand {
        CodableBrand(
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

private extension CodableRemoteBrandStore {
    struct CodableCache: Codable {
        let brand: CodableBrand
        let timestamp: Date
    }

    struct CodableBrand: Codable {
        let listingsHost: URL
        let listingsPageSize: Int
        let listingsCacheMaxAgeInDays: Int
        let defaultLanguage: String
        let supportedLanguages: [String]
        let tabs: [String]
    }
}
