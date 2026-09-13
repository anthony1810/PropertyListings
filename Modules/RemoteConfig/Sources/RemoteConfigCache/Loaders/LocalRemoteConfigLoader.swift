import Foundation
import RemoteConfigFeature

public struct LocalRemoteConfigLoader: Sendable {
    public enum Error: Swift.Error, Equatable { case cacheMiss }

    private let store: RemoteConfigStore
    private let policy: RemoteConfigCachePolicy
    private let currentDate: @Sendable () -> Date

    public init(
        store: RemoteConfigStore,
        policy: RemoteConfigCachePolicy,
        currentDate: @escaping @Sendable () -> Date
    ) {
        self.store = store
        self.policy = policy
        self.currentDate = currentDate
    }

    public func load() async throws -> RemoteConfig {
        guard let cache = try await store.retrieve(),
            policy.validate(cache.timestamp, against: currentDate())
        else { throw Error.cacheMiss }
        return Self.configuration(from: cache.configuration)
    }

    public func save(_ configuration: RemoteConfig) async throws {
        try await store.insert(Self.local(from: configuration), timestamp: currentDate())
    }
}

// MARK: - Local to domain

private extension LocalRemoteConfigLoader {
    static func configuration(from local: LocalRemoteConfig) -> RemoteConfig {
        RemoteConfig(
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

private extension LocalRemoteConfigLoader {
    static func local(from configuration: RemoteConfig) -> LocalRemoteConfig {
        LocalRemoteConfig(
            listingsHost: configuration.listingsHost,
            listingsPageSize: configuration.listingsPageSize,
            listingsCacheMaxAgeInDays: configuration.listingsCacheMaxAgeInDays,
            defaultLanguage: configuration.defaultLanguage,
            supportedLanguages: configuration.supportedLanguages,
            tabs: configuration.tabs
        )
    }
}
