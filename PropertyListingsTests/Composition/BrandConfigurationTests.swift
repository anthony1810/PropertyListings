import DesignSystem
import Foundation
import RemoteConfigFeature
import SettingsFeature
import Testing
@testable import PropertyListings

@Suite struct BrandConfigurationTests {
    // MARK: - Settings

    @Test func initialLanguage_isTheDeviceLanguage_whenTheBrandSupportsIt() {
        let brandSettings = BrandConfiguration.Settings(
            defaultLanguage: .english,
            supportedLanguages: [.german, .french, .english]
        )

        #expect(brandSettings.initialLanguage(preferring: ["fr", "en"]) == .french)
    }

    @Test func initialLanguage_isTheBrandDefault_whenNoDeviceLanguageIsSupported() {
        let unsupported = AppLanguage.italian
        let brandSettings = BrandConfiguration.Settings(
            defaultLanguage: .french,
            supportedLanguages: [.english, .french]
        )

        #expect(brandSettings.initialLanguage(preferring: [unsupported.rawValue]) == .french)
    }

    @Test func initialLanguage_skipsADeviceLanguageTheAppDoesNotKnow() {
        let unknownToTheApp = "ja"
        let brandSettings = BrandConfiguration.Settings(
            defaultLanguage: .english,
            supportedLanguages: [.german, .english]
        )

        #expect(brandSettings.initialLanguage(preferring: [unknownToTheApp, "de"]) == .german)
    }

    // MARK: - Building from a remote document

    @Test func initRemote_isTheRemoteBrand_whenTheDocumentIsUsable() {
        let fallback = makeBrand()
        let remote = makeRemoteBrand()

        let brand = BrandConfiguration(remote: remote, fallback: fallback)

        #expect(brand?.listings.host == remote.listingsHost)
        #expect(brand?.listings.pageSize == remote.listingsPageSize)
        #expect(brand?.listings.cacheMaxAgeInDays == remote.listingsCacheMaxAgeInDays)
        #expect(brand?.settings.defaultLanguage == .english)
        #expect(brand?.settings.supportedLanguages == [.english, .vietnamese])
        #expect(brand?.tabs.map(\.destination) == [.listings, .settings])
    }

    @Test func initRemote_keepsTheFallbackTheme() {
        let fallback = makeBrand(theme: makeTheme(radii: DSRadii(m: 3, l: 5)))

        let brand = BrandConfiguration(remote: makeRemoteBrand(), fallback: fallback)

        #expect(brand?.theme == fallback.theme)
    }

    @Test func initRemote_keepsTheFallbackIconForEveryTab() {
        let fallback = makeBrand(tabs: [
            BrandConfiguration.Tab(destination: .listings, icon: .image("TabListings")),
            BrandConfiguration.Tab(destination: .settings, icon: .image("TabSettings")),
        ])

        let brand = BrandConfiguration(remote: makeRemoteBrand(), fallback: fallback)

        #expect(brand?.tabs.map(\.icon) == [.image("TabListings"), .image("TabSettings")])
    }

    @Test func initRemote_isNothing_whenTheHostIsNotSecure() {
        let insecure = URL(string: "http://brand.example/api")!

        #expect(
            BrandConfiguration(remote: makeRemoteBrand(host: insecure), fallback: makeBrand())
                == nil
        )
    }

    @Test func initRemote_isNothing_whenALanguageIsUnknownToTheApp() {
        let unknownToTheApp = "ja"

        #expect(
            BrandConfiguration(
                remote: makeRemoteBrand(supportedLanguages: ["en", unknownToTheApp]),
                fallback: makeBrand()
            ) == nil
        )
    }

    @Test func initRemote_isNothing_whenTheDefaultLanguageIsNotSupported() {
        #expect(
            BrandConfiguration(
                remote: makeRemoteBrand(defaultLanguage: "de", supportedLanguages: ["en", "vi"]),
                fallback: makeBrand()
            ) == nil
        )
    }

    @Test func initRemote_isNothing_whenATabIsNotOneTheBrandBuilds() {
        let fallback = makeBrand(tabs: [
            BrandConfiguration.Tab(destination: .listings, icon: .symbol("house")),
            BrandConfiguration.Tab(destination: .settings, icon: .symbol("gear")),
        ])

        #expect(
            BrandConfiguration(
                remote: makeRemoteBrand(tabs: ["listings", "saved"]),
                fallback: fallback
            ) == nil
        )
    }

    @Test func initRemote_isNothing_whenTheTabsDropListings() {
        #expect(
            BrandConfiguration(remote: makeRemoteBrand(tabs: ["settings"]), fallback: makeBrand())
                == nil
        )
    }

    // MARK: - Helpers

    private func makeRemoteBrand(
        host: URL = URL(string: "https://staging.brand.example/api")!,
        pageSize: Int = 4,
        cacheMaxAgeInDays: Int = 3,
        defaultLanguage: String = "en",
        supportedLanguages: [String] = ["en", "vi"],
        tabs: [String] = ["listings", "settings"]
    ) -> RemoteBrand {
        RemoteBrand(
            listingsHost: host,
            listingsPageSize: pageSize,
            listingsCacheMaxAgeInDays: cacheMaxAgeInDays,
            defaultLanguage: defaultLanguage,
            supportedLanguages: supportedLanguages,
            tabs: tabs
        )
    }
}
