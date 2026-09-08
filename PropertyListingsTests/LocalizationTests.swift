import Foundation
import Testing
import TestSupport

@Suite struct LocalizationTests {
    @Test func appCatalog_isTranslatedInEveryLanguage() {
        verifyLocalizationCoverage(in: .main, languages: ["en", "de", "fr", "it"])
    }

    @Test func errorTitle_resolvesPerLanguage() throws {
        let german = try #require(Bundle.main.path(forResource: "de", ofType: "lproj").flatMap(Bundle.init(path:)))

        #expect(String(localized: "alert.errorTitle", bundle: german) == "Etwas ist schiefgelaufen")
    }
}
