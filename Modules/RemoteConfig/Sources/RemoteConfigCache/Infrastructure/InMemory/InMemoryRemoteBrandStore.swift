import Foundation

public actor InMemoryRemoteBrandStore: RemoteBrandStore {
    private var cache: CachedRemoteBrand?

    public init(cache: CachedRemoteBrand? = nil) {
        self.cache = cache
    }

    public func retrieve() async throws -> CachedRemoteBrand? {
        cache
    }

    public func insert(_ brand: LocalRemoteBrand, timestamp: Date) async throws {
        cache = CachedRemoteBrand(brand: brand, timestamp: timestamp)
    }
}
