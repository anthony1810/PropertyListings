import Foundation
import SettingsPresentation
import Testing
import TestSupport

@Suite struct LocalizationTests {
    @Test func catalog_isTranslatedInEveryLanguage() {
        verifyLocalizationCoverage(in: SettingsPresentationResources.bundle, languages: ["en", "de", "fr", "it"])
    }

    @Test func saveFailed_resolvesPerLanguage() {
        let german = SettingsViewModel.Message.saveFailed(Locale(identifier: "de_CH"))

        #expect(german.hasPrefix("Ihre Auswahl konnte nicht gespeichert werden"))
    }
}
