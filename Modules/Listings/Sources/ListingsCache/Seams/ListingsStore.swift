import Foundation

public protocol ListingsStore: Sendable {
    func retrieve() async throws -> CachedListings?
    func insert(_ listings: [LocalListing], timestamp: Date) async throws
    func deleteCachedListings() async throws
}
