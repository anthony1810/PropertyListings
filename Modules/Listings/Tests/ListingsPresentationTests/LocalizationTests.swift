import Foundation
import ListingsPresentation
import Testing
import TestSupport

@Suite struct LocalizationTests {
    @Test func catalog_isTranslatedInEveryLanguage() {
        verifyLocalizationCoverage(in: ListingsPresentationResources.bundle, languages: ["en", "de", "fr", "it"])
    }

    @Test func listingsFailed_resolvesPerLanguage() throws {
        let german = try #require(ListingsPresentationResources.bundle.path(forResource: "de", ofType: "lproj").flatMap(Bundle.init(path:)))

        #expect(String(localized: "listings.loadFailed", bundle: german).hasPrefix("Inserate konnten nicht geladen werden"))
    }
}
