#if canImport(UIKit)
import Foundation
import SettingsUI
import Testing
import TestSupport

@Suite struct LocalizationTests {
    @Test func catalog_isTranslatedInEveryLanguage() {
        verifyLocalizationCoverage(in: SettingsUIResources.bundle, languages: ["en", "de", "fr", "it"])
    }

    @Test func title_resolvesPerLanguage() throws {
        let german = try #require(SettingsUIResources.bundle.path(forResource: "de", ofType: "lproj").flatMap(Bundle.init(path:)))

        #expect(String(localized: "settings.title", bundle: german) == "Einstellungen")
    }
}
#endif
