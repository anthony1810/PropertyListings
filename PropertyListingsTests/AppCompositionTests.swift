import BookmarksPersistence
import Foundation
import ListingsCache
import Testing
import TestSupport
@testable import PropertyListings

@MainActor
@Suite struct AppCompositionTests {
    @Test func listingsViewModel_isOneInstanceAcrossAccesses() {
        let sut = makeSUT()

        #expect(sut.listingsViewModel === sut.listingsViewModel)
    }

    @Test func bookmarksViewModel_isOneInstanceAcrossAccesses() {
        let sut = makeSUT()

        #expect(sut.bookmarksViewModel === sut.bookmarksViewModel)
    }

    // MARK: - Helpers

    private func makeSUT() -> AppComposition {
        let now = Date()
        return AppComposition(
            httpClient: HTTPClientStub.offline,
            listingsStore: InMemoryListingsStore(),
            bookmarkStore: InMemoryBookmarkStore(),
            currentDate: { now },
            locale: Locale(identifier: "de_CH")
        )
    }
}
