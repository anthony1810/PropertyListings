import Foundation
import RemoteConfigFeature

public struct LocalRemoteBrandLoader: Sendable {
    public enum Error: Swift.Error, Equatable { case cacheMiss }

    private let store: RemoteBrandStore
    private let policy: RemoteConfigCachePolicy
    private let currentDate: @Sendable () -> Date

    public init(
        store: RemoteBrandStore,
        policy: RemoteConfigCachePolicy,
        currentDate: @escaping @Sendable () -> Date
    ) {
        self.store = store
        self.policy = policy
        self.currentDate = currentDate
    }

    public func load() async throws -> RemoteBrand {
        guard let cache = try await store.retrieve(),
            policy.validate(cache.timestamp, against: currentDate())
        else { throw Error.cacheMiss }
        return Self.brand(from: cache.brand)
    }

    public func save(_ brand: RemoteBrand) async throws {
        try await store.insert(Self.local(from: brand), timestamp: currentDate())
    }
}

// MARK: - Local to domain

private extension LocalRemoteBrandLoader {
    static func brand(from local: LocalRemoteBrand) -> RemoteBrand {
        RemoteBrand(
            listingsHost: local.listingsHost,
            listingsPageSize: local.listingsPageSize,
            listingsCacheMaxAgeInDays: local.listingsCacheMaxAgeInDays,
            defaultLanguage: local.defaultLanguage,
            supportedLanguages: local.supportedLanguages,
            tabs: local.tabs
        )
    }
}

// MARK: - Domain to local

private extension LocalRemoteBrandLoader {
    static func local(from brand: RemoteBrand) -> LocalRemoteBrand {
        LocalRemoteBrand(
            listingsHost: brand.listingsHost,
            listingsPageSize: brand.listingsPageSize,
            listingsCacheMaxAgeInDays: brand.listingsCacheMaxAgeInDays,
            defaultLanguage: brand.defaultLanguage,
            supportedLanguages: brand.supportedLanguages,
            tabs: brand.tabs
        )
    }
}
