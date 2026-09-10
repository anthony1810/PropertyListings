import BookmarksPresentation
import Foundation
import Testing
import TestSupport

@Suite struct LocalizationTests {
    @Test func catalog_isTranslatedInEveryLanguage() {
        verifyLocalizationCoverage(in: BookmarksPresentationResources.bundle, languages: ["en", "de", "fr", "it"])
    }

    @Test func removeFailed_resolvesPerLanguage() {
        let german = BookmarksViewModel.Message.removeFailed(Locale(identifier: "de_CH"))

        #expect(german.hasPrefix("Dieses Inserat konnte nicht entfernt werden"))
    }
}
