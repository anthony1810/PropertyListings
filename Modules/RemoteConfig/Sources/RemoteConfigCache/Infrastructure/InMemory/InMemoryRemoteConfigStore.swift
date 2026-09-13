import Foundation

public actor InMemoryRemoteConfigStore: RemoteConfigStore {
    private var cache: CachedRemoteConfig?

    public init(cache: CachedRemoteConfig? = nil) {
        self.cache = cache
    }

    public func retrieve() async throws -> CachedRemoteConfig? {
        cache
    }

    public func insert(_ configuration: LocalRemoteConfig, timestamp: Date) async throws {
        cache = CachedRemoteConfig(configuration: configuration, timestamp: timestamp)
    }
}
