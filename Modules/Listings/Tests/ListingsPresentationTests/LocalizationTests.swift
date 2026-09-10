import Foundation
import ListingsPresentation
import Testing
import TestSupport

@Suite struct LocalizationTests {
    @Test func catalog_isTranslatedInEveryLanguage() {
        verifyLocalizationCoverage(in: ListingsPresentationResources.bundle, languages: ["en", "de", "fr", "it"])
    }

    @Test func listingsFailed_resolvesPerLanguage() {
        let german = ListingsViewModel.Message.listingsFailed(Locale(identifier: "de_CH"))

        #expect(german.hasPrefix("Inserate konnten nicht geladen werden"))
    }

    @Test func bookmarkNotSaved_resolvesPerLanguage() {
        let french = ListingsViewModel.Message.bookmarkNotSaved(Locale(identifier: "fr_CH"))

        #expect(french != ListingsViewModel.Message.bookmarkNotSaved(Locale(identifier: "de_CH")))
    }
}
