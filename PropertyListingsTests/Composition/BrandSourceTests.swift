import Foundation
import RemoteConfigCache
import RemoteConfigFeature
import Testing
import TestSupport
@testable import PropertyListings

struct BrandSourceTests {
    @Test func brand_isTheFallback_whenNothingIsCached() async {
        let source = makeSource()

        let brand = await source.brand(store: InMemoryRemoteBrandStore())

        #expect(brand == source.fallback)
    }

    @Test func brand_isTheCachedDocument_whenItIsUsable() async {
        let source = makeSource()
        let cached = CachedRemoteBrand(brand: usableDocument, timestamp: now)

        let brand = await source.brand(
            store: InMemoryRemoteBrandStore(cache: cached),
            currentDate: { [now] in now }
        )

        #expect(brand.listings.pageSize == usableDocument.listingsPageSize)
        #expect(brand.theme == source.fallback.theme)
    }

    @Test func brand_isTheFallback_whenTheCachedDocumentIsNotUsable() async {
        let source = makeSource()
        let insecure = LocalRemoteBrand(
            listingsHost: URL(string: "http://brand.example")!,
            listingsPageSize: usableDocument.listingsPageSize,
            listingsCacheMaxAgeInDays: usableDocument.listingsCacheMaxAgeInDays,
            defaultLanguage: usableDocument.defaultLanguage,
            supportedLanguages: usableDocument.supportedLanguages,
            tabs: usableDocument.tabs
        )

        let brand = await source.brand(
            store: InMemoryRemoteBrandStore(
                cache: CachedRemoteBrand(brand: insecure, timestamp: now)
            ),
            currentDate: { [now] in now }
        )

        #expect(brand == source.fallback)
    }

    @Test func brand_isTheFallback_whenTheCachedDocumentReachedTheMaxAge() async {
        let source = makeSource()
        let age = BrandSource.cachePolicy.maxAgeInDays
        let expired = CachedRemoteBrand(brand: usableDocument, timestamp: now.adding(days: -age))

        let brand = await source.brand(
            store: InMemoryRemoteBrandStore(cache: expired),
            currentDate: { [now] in now }
        )

        #expect(brand == source.fallback)
    }

    // MARK: - Helpers

    private let now = Date()
    private let usableDocument = LocalRemoteBrand(
        listingsHost: URL(string: "https://staging.brand.example/api")!,
        listingsPageSize: 4,
        listingsCacheMaxAgeInDays: 3,
        defaultLanguage: "en",
        supportedLanguages: ["en", "vi"],
        tabs: ["listings", "settings"]
    )

    private func makeSource() -> BrandSource {
        BrandSource(documentURL: nil, fallback: makeBrand(listingsPageSize: 5))
    }
}
