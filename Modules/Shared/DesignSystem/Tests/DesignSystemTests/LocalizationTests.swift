import Testing
import TestSupport
@testable import DesignSystem

@Suite struct LocalizationTests {
    @Test func catalog_isTranslatedInEveryLanguage() {
        verifyLocalizationCoverage(in: DesignSystemResources.bundle, languages: ["en", "de", "fr", "it"])
    }

    @Test func verifyLocalizationCoverage_reportsALanguageWithoutTranslations() {
        withKnownIssue {
            verifyLocalizationCoverage(in: DesignSystemResources.bundle, languages: ["en", "de", "fr", "it", "rm"])
        }
    }
}
