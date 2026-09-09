import BookmarksPresentation
import Foundation
import Testing
import TestSupport

@Suite struct LocalizationTests {
    @Test func catalog_isTranslatedInEveryLanguage() {
        verifyLocalizationCoverage(in: BookmarksPresentationResources.bundle, languages: ["en", "de", "fr", "it"])
    }

    @Test func removeFailed_resolvesPerLanguage() throws {
        let german = try #require(BookmarksPresentationResources.bundle.path(forResource: "de", ofType: "lproj").flatMap(Bundle.init(path:)))

        #expect(String(localized: "bookmarks.removeFailed", bundle: german).hasPrefix("Dieses Inserat konnte nicht entfernt werden"))
    }
}
