#if canImport(UIKit)
import Foundation
import ListingsUI
import Testing
import TestSupport

@Suite struct LocalizationTests {
    @Test func catalog_isTranslatedInEveryLanguage() {
        verifyLocalizationCoverage(in: ListingsUIResources.bundle, languages: ["en", "de", "fr", "it"])
    }

    @Test func title_resolvesPerLanguage() throws {
        let german = try #require(ListingsUIResources.bundle.path(forResource: "de", ofType: "lproj").flatMap(Bundle.init(path:)))

        #expect(String(localized: "listings.title", bundle: german) == "Inserate")
    }
}
#endif
