import Foundation

public actor CodableListingsStore: ListingsStore {
    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retrieve() async throws -> CachedListings? {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return nil }
        let data = try Data(contentsOf: storeURL)
        return Self.cachedListings(from: try JSONDecoder().decode(CodableCache.self, from: data))
    }

    public func insert(_ listings: [LocalListing], timestamp: Date) async throws {
        let cache = Self.codableCache(from: listings, timestamp: timestamp)
        try JSONEncoder().encode(cache).write(to: storeURL, options: .atomic)
    }

    public func deleteCachedListings() async throws {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return }
        try FileManager.default.removeItem(at: storeURL)
    }
}

// MARK: - Codable to local

private extension CodableListingsStore {
    static func cachedListings(from cache: CodableCache) -> CachedListings {
        CachedListings(listings: cache.listings.map(local(from:)), timestamp: cache.timestamp)
    }

    static func local(from codable: CodableListing) -> LocalListing {
        LocalListing(
            id: codable.id,
            title: codable.title,
            priceAmount: codable.priceAmount,
            priceCurrency: codable.priceCurrency,
            street: codable.street,
            postalCode: codable.postalCode,
            locality: codable.locality,
            imageURL: codable.imageURL
        )
    }
}

// MARK: - Local to Codable

private extension CodableListingsStore {
    static func codableCache(from listings: [LocalListing], timestamp: Date) -> CodableCache {
        CodableCache(listings: listings.map(codable(from:)), timestamp: timestamp)
    }

    static func codable(from local: LocalListing) -> CodableListing {
        CodableListing(
            id: local.id,
            title: local.title,
            priceAmount: local.priceAmount,
            priceCurrency: local.priceCurrency,
            street: local.street,
            postalCode: local.postalCode,
            locality: local.locality,
            imageURL: local.imageURL
        )
    }
}

// MARK: - Codable representation

private extension CodableListingsStore {
    struct CodableCache: Codable {
        let listings: [CodableListing]
        let timestamp: Date
    }

    struct CodableListing: Codable {
        let id: String
        let title: String
        let priceAmount: Decimal?
        let priceCurrency: String?
        let street: String?
        let postalCode: String?
        let locality: String
        let imageURL: URL?
    }
}
