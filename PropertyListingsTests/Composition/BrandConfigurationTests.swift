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

    // MARK: - Applying a remote document

    @Test func applying_keepsTheBrand_whenTheDocumentIsEmpty() {
        let brand = makeBrand()

        #expect(brand.applying(RemoteConfig()) == brand)
    }

    @Test func applying_takesTheListingsHost_whenItIsSecure() {
        let staging = URL(string: "https://staging.brand.example/api")!
        let brand = makeBrand()

        let applied = brand.applying(RemoteConfig(listingsHost: staging))

        #expect(applied.listings.host == staging)
    }

    @Test func applying_keepsTheListingsHost_whenTheDocumentAsksForCleartext() {
        let insecure = URL(string: "http://staging.brand.example/api")!
        let brand = makeBrand()

        let applied = brand.applying(RemoteConfig(listingsHost: insecure))

        #expect(applied.listings.host == brand.listings.host)
    }

    @Test(arguments: [1, 50])
    func applying_takesThePageSize_whenItIsWithinBounds(pageSize: Int) {
        let brand = makeBrand()

        #expect(
            brand.applying(RemoteConfig(listingsPageSize: pageSize)).listings.pageSize == pageSize
        )
    }

    @Test(arguments: [0, 51])
    func applying_keepsThePageSize_whenTheDocumentIsOutOfBounds(pageSize: Int) {
        let brand = makeBrand(listingsPageSize: 5)

        #expect(brand.applying(RemoteConfig(listingsPageSize: pageSize)).listings.pageSize == 5)
    }

    @Test(arguments: [1, 30])
    func applying_takesTheCacheAge_whenItIsWithinBounds(days: Int) {
        let brand = makeBrand()

        #expect(
            brand.applying(RemoteConfig(listingsCacheMaxAgeInDays: days)).listings.cacheMaxAgeInDays
                == days
        )
    }

    @Test(arguments: [0, 31])
    func applying_keepsTheCacheAge_whenTheDocumentIsOutOfBounds(days: Int) {
        let brand = makeBrand(listingsCacheMaxAgeInDays: 7)

        #expect(
            brand.applying(RemoteConfig(listingsCacheMaxAgeInDays: days)).listings.cacheMaxAgeInDays
                == 7
        )
    }

    @Test func applying_takesTheSupportedLanguagesTheAppKnows() {
        let unknownToTheApp = "ja"
        let brand = makeBrand(supportedLanguages: AppLanguage.allCases)

        let applied = brand.applying(
            RemoteConfig(supportedLanguages: ["en", unknownToTheApp, "vi"])
        )

        #expect(applied.settings.supportedLanguages == [.english, .vietnamese])
    }

    @Test func applying_keepsTheSupportedLanguages_whenNoneAreKnownToTheApp() {
        let brand = makeBrand(supportedLanguages: [.german, .english])

        let applied = brand.applying(RemoteConfig(supportedLanguages: ["ja", "ko"]))

        #expect(applied.settings.supportedLanguages == brand.settings.supportedLanguages)
    }

    @Test func applying_takesTheDefaultLanguage_whenTheAppliedListSupportsIt() {
        let brand = makeBrand(
            defaultLanguage: .english,
            supportedLanguages: [.english, .vietnamese]
        )

        let applied = brand.applying(RemoteConfig(defaultLanguage: "vi"))

        #expect(applied.settings.defaultLanguage == .vietnamese)
    }

    @Test func applying_keepsTheDefaultLanguage_whenTheAppliedListDoesNotSupportIt() {
        let brand = makeBrand(
            defaultLanguage: .english,
            supportedLanguages: [.english, .vietnamese]
        )

        let applied = brand.applying(RemoteConfig(defaultLanguage: "de"))

        #expect(applied.settings.defaultLanguage == .english)
    }

    @Test func applying_takesTheTabsTheBrandAlreadyBuilds() {
        let brand = makeBrand(tabs: [
            BrandConfiguration.Tab(destination: .listings, icon: .symbol("house")),
            BrandConfiguration.Tab(destination: .saved, icon: .symbol("heart")),
            BrandConfiguration.Tab(destination: .settings, icon: .symbol("gear")),
        ])

        let applied = brand.applying(RemoteConfig(tabs: ["settings", "listings"]))

        #expect(applied.tabs.map(\.destination) == [.settings, .listings])
        #expect(applied.tabs.map(\.icon) == [.symbol("gear"), .symbol("house")])
    }

    @Test func applying_keepsTheTabs_whenTheDocumentNamesTabsTheBrandDoesNotBuild() {
        let brand = makeBrand(tabs: [
            BrandConfiguration.Tab(destination: .listings, icon: .symbol("house")),
            BrandConfiguration.Tab(destination: .settings, icon: .symbol("gear")),
        ])

        let applied = brand.applying(RemoteConfig(tabs: ["saved"]))

        #expect(applied.tabs == brand.tabs)
    }

    @Test func applying_keepsTheTabs_whenTheDocumentDropsListings() {
        let brand = makeBrand()

        let applied = brand.applying(RemoteConfig(tabs: ["settings"]))

        #expect(applied.tabs == brand.tabs)
    }

    @Test func applying_takesTheFirstSupportedLanguageAsDefault_whenNeitherChoiceSurvives() {
        let brand = makeBrand(defaultLanguage: .german, supportedLanguages: [.german, .french])

        let applied = brand.applying(
            RemoteConfig(defaultLanguage: "it", supportedLanguages: ["vi", "en"])
        )

        #expect(applied.settings.defaultLanguage == .vietnamese)
        #expect(applied.settings.supportedLanguages == [.vietnamese, .english])
    }

    @Test func applying_keepsTheTheme() {
        let brand = makeBrand(theme: makeTheme(radii: DSRadii(m: 3, l: 5)))

        #expect(brand.applying(RemoteConfig(listingsPageSize: 4)).theme == brand.theme)
    }
}
