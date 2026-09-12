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
}
