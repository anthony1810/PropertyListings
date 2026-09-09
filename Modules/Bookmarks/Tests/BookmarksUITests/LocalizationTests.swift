#if canImport(UIKit)
import BookmarksUI
import Foundation
import Testing
import TestSupport

@Suite struct LocalizationTests {
    @Test func catalog_isTranslatedInEveryLanguage() {
        verifyLocalizationCoverage(in: BookmarksUIResources.bundle, languages: ["en", "de", "fr", "it"])
    }

    @Test func title_resolvesPerLanguage() throws {
        let german = try #require(BookmarksUIResources.bundle.path(forResource: "de", ofType: "lproj").flatMap(Bundle.init(path:)))

        #expect(String(localized: "bookmarks.title", bundle: german) == "Gespeichert")
    }
}
#endif
