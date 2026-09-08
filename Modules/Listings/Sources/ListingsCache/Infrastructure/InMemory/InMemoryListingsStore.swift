import Foundation

public actor InMemoryListingsStore: ListingsStore {
    private var cache: CachedListings?

    public init(cache: CachedListings? = nil) {
        self.cache = cache
    }

    public func retrieve() async throws -> CachedListings? {
        cache
    }

    public func insert(_ listings: [LocalListing], timestamp: Date) async throws {
        cache = CachedListings(listings: listings, timestamp: timestamp)
    }

    public func deleteCachedListings() async throws {
        cache = nil
    }
}
