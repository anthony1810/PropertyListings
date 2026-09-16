import Foundation
import RemoteConfigAPI
import RemoteConfigCache
import RemoteConfigFeature
import Testing
import TestSupport
@testable import PropertyListings

struct RemoteConfigServiceTests {
    // MARK: - Cached brand

    @Test func cachedBrand_isNothing_whenTheCacheIsEmpty() async {
        let sut = makeSUT(client: .offline)

        #expect(await sut.cachedBrand() == nil)
    }

    @Test func cachedBrand_isTheCachedDocument_whenTheCacheIsFresh() async {
        let pair = makeRemoteBrandPair()
        let store = InMemoryRemoteBrandStore(
            cache: CachedRemoteBrand(brand: pair.local, timestamp: now)
        )
        let sut = makeSUT(client: .offline, store: store)

        #expect(await sut.cachedBrand() == pair.model)
    }

    @Test func cachedBrand_isNothing_whenTheCacheReachedTheMaxAge() async {
        let pair = makeRemoteBrandPair()
        let expired = CachedRemoteBrand(
            brand: pair.local,
            timestamp: now.adding(days: -maxAgeInDays)
        )
        let sut = makeSUT(client: .offline, store: InMemoryRemoteBrandStore(cache: expired))

        #expect(await sut.cachedBrand() == nil)
    }

    // MARK: - Refresh

    @Test func refresh_cachesTheRemoteDocument() async {
        let sut = makeSUT(client: online)

        await sut.refresh()

        #expect(await sut.cachedBrand() == makeRemoteBrandPair().model)
    }

    @Test func refresh_keepsTheCachedDocument_whenTheRequestFails() async {
        let pair = makeRemoteBrandPair()
        let store = InMemoryRemoteBrandStore(
            cache: CachedRemoteBrand(brand: pair.local, timestamp: now)
        )
        let sut = makeSUT(client: .offline, store: store)

        await sut.refresh()

        #expect(await sut.cachedBrand() == pair.model)
    }

    @Test func refresh_keepsTheCachedDocument_whenTheDocumentIsIncomplete() async {
        let pair = makeRemoteBrandPair()
        let store = InMemoryRemoteBrandStore(
            cache: CachedRemoteBrand(brand: pair.local, timestamp: now)
        )
        let incomplete = HTTPClientStub([documentURL: [.success(invalidJSON())]])
        let sut = makeSUT(client: incomplete, store: store)

        await sut.refresh()

        #expect(await sut.cachedBrand() == pair.model)
    }

    // MARK: - Helpers

    private let now = Date()
    private let maxAgeInDays = 7
    private let baseURL = anyURL()

    private var documentURL: URL { RemoteBrandEndpoint.current.url(baseURL: baseURL) }

    private var online: HTTPClientStub {
        HTTPClientStub([documentURL: [.success(document)]])
    }

    private var document: Data {
        let brand = makeRemoteBrandPair().model
        return try! JSONSerialization.data(withJSONObject: [
            "listings": [
                "host": brand.listingsHost.absoluteString,
                "pageSize": brand.listingsPageSize,
                "cacheMaxAgeInDays": brand.listingsCacheMaxAgeInDays,
            ],
            "settings": [
                "defaultLanguage": brand.defaultLanguage,
                "supportedLanguages": brand.supportedLanguages,
            ],
            "tabs": brand.tabs,
        ])
    }

    private func makeRemoteBrandPair() -> (model: RemoteBrand, local: LocalRemoteBrand) {
        let model = RemoteBrand(
            listingsHost: URL(string: "https://staging.brand.example/api")!,
            listingsPageSize: 4,
            listingsCacheMaxAgeInDays: 3,
            defaultLanguage: "en",
            supportedLanguages: ["en", "vi"],
            tabs: ["listings", "settings"]
        )
        let local = LocalRemoteBrand(
            listingsHost: model.listingsHost,
            listingsPageSize: model.listingsPageSize,
            listingsCacheMaxAgeInDays: model.listingsCacheMaxAgeInDays,
            defaultLanguage: model.defaultLanguage,
            supportedLanguages: model.supportedLanguages,
            tabs: model.tabs
        )
        return (model, local)
    }

    private func makeSUT(
        client: HTTPClientStub,
        store: RemoteBrandStore = InMemoryRemoteBrandStore()
    ) -> RemoteConfigService {
        RemoteConfigService(
            httpClient: client,
            store: store,
            baseURL: baseURL,
            cachePolicy: RemoteConfigCachePolicy(maxAgeInDays: maxAgeInDays),
            currentDate: { [now] in now }
        )
    }
}
