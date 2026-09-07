import Foundation
import Testing
import TestSupport
@testable import SharedPresentation

@Suite struct LocalizationTests {
    @Test func catalog_isTranslatedInEveryLanguage() {
        verifyLocalizationCoverage(in: SharedPresentationResources.bundle, languages: ["en", "de", "fr", "it"])
    }

    @Test func onRequest_resolvesPerLanguage() throws {
        let german = try #require(SharedPresentationResources.bundle.path(forResource: "de", ofType: "lproj").flatMap(Bundle.init(path:)))
        #expect(String(localized: "price.onRequest", bundle: german) == "Preis auf Anfrage")
    }
}
