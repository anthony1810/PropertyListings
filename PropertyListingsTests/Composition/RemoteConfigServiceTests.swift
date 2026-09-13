import Foundation
import RemoteConfigAPI
import RemoteConfigCache
import RemoteConfigFeature
import Testing
import TestSupport
@testable import PropertyListings

struct RemoteConfigServiceTests {
    // MARK: - Cached configuration

    @Test func cachedConfiguration_hasNoOverrides_whenTheCacheIsEmpty() async {
        let sut = makeSUT(client: .offline)

        #expect(await sut.cachedConfiguration() == RemoteConfig())
    }

    @Test func cachedConfiguration_isTheCachedDocument_whenTheCacheIsFresh() async {
        let cached = makeCachedConfiguration(pageSize: pageSize)
        let sut = makeSUT(client: .offline, store: InMemoryRemoteConfigStore(cache: cached))

        #expect(await sut.cachedConfiguration() == RemoteConfig(listingsPageSize: pageSize))
    }

    @Test func cachedConfiguration_hasNoOverrides_whenTheCacheReachedTheMaxAge() async {
        let expired = makeCachedConfiguration(pageSize: pageSize, age: maxAgeInDays)
        let sut = makeSUT(client: .offline, store: InMemoryRemoteConfigStore(cache: expired))

        #expect(await sut.cachedConfiguration() == RemoteConfig())
    }

    // MARK: - Refresh

    @Test func refresh_cachesTheRemoteDocument() async {
        let store = InMemoryRemoteConfigStore()
        let sut = makeSUT(client: online, store: store)

        await sut.refresh()

        #expect(await sut.cachedConfiguration() == RemoteConfig(listingsPageSize: pageSize))
    }

    @Test func refresh_keepsTheCachedDocument_whenTheRequestFails() async {
        let cached = makeCachedConfiguration(pageSize: pageSize)
        let sut = makeSUT(client: .offline, store: InMemoryRemoteConfigStore(cache: cached))

        await sut.refresh()

        #expect(await sut.cachedConfiguration() == RemoteConfig(listingsPageSize: pageSize))
    }

    @Test func refresh_keepsTheCachedDocument_whenTheResponseIsInvalid() async {
        let cached = makeCachedConfiguration(pageSize: pageSize)
        let malformed = HTTPClientStub([configurationURL: [.success(invalidJSON())]])
        let sut = makeSUT(client: malformed, store: InMemoryRemoteConfigStore(cache: cached))

        await sut.refresh()

        #expect(await sut.cachedConfiguration() == RemoteConfig(listingsPageSize: pageSize))
    }

    // MARK: - Helpers

    private let now = Date()
    private let pageSize = 4
    private let maxAgeInDays = 7
    private let configurationURL = RemoteConfigEndpoint.current.url(baseURL: anyURL())

    private var online: HTTPClientStub {
        HTTPClientStub([configurationURL: [.success(remoteConfigJSON(pageSize: pageSize))]])
    }

    private func makeCachedConfiguration(pageSize: Int, age: Int = 0) -> CachedRemoteConfig {
        CachedRemoteConfig(
            configuration: LocalRemoteConfig(
                listingsHost: nil,
                listingsPageSize: pageSize,
                listingsCacheMaxAgeInDays: nil,
                defaultLanguage: nil,
                supportedLanguages: nil,
                tabs: nil
            ),
            timestamp: now.adding(days: -age)
        )
    }

    private func remoteConfigJSON(pageSize: Int) -> Data {
        try! JSONSerialization.data(withJSONObject: ["listings": ["pageSize": pageSize]])
    }

    private func makeSUT(
        client: HTTPClientStub,
        store: RemoteConfigStore = InMemoryRemoteConfigStore()
    ) -> RemoteConfigService {
        RemoteConfigService(
            httpClient: client,
            store: store,
            baseURL: anyURL(),
            cachePolicy: RemoteConfigCachePolicy(maxAgeInDays: maxAgeInDays),
            currentDate: { [now] in now }
        )
    }
}
