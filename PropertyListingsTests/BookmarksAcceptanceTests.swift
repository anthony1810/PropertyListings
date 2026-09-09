import BookmarksFeature
import BookmarksPersistence
import BookmarksPresentation
import BookmarksTestSupport
import Foundation
import ListingsAPI
import ListingsCache
import ListingsFeature
import ListingsPresentation
import Testing
import TestSupport
@testable import PropertyListings

@MainActor
struct BookmarksAcceptanceTests {
    // MARK: - Narrative 2, the Saved tab

    @Test func customerOpensSaved_seesEveryLikedListingNewestFirst() async {
        let older = makeBookmark(id: "1", title: "Haus", savedAt: now.adding(seconds: -60))
        let newer = makeBookmark(id: "2", title: "Chalet", savedAt: now)
        let app = launch(.offline, bookmarks: [older, newer])

        await app.observingBookmarks {
            #expect(app.saved.rows == [
                BookmarkRowMapper.map(newer, locale: deCH),
                BookmarkRowMapper.map(older, locale: deCH),
            ], "the Saved tab lists the newer bookmark first")
        }
    }

    @Test func customerOpensSavedWithNoLikes_seesNothingToShow() async {
        let app = launch(.offline)

        await app.observingBookmarks {
            #expect(app.saved.rows == [], "the Saved tab has no rows")
        }
    }

    @Test func customerLikesOnListings_seesItAppearOnSaved() async {
        let app = launch(online)
        await app.listings.load()

        await app.observingBookmarks {
            await app.like(house.model)

            #expect(app.savedIDs == [house.model.id], "the liked listing is the only row on the Saved tab")
        }
    }

    // MARK: - Narrative 3, removing on Saved

    @Test func customerRemovesOnSaved_seesTheRowLeaveAndTheHeartClearOnListings() async {
        let app = launch(online, bookmarks: [Bookmark(listing: house.model, savedAt: now)])
        await app.listings.load()

        await app.observingBookmarks {
            await app.saved.remove(id: house.model.id)
            await Task.megaYield()

            #expect(app.saved.rows == [], "the Saved tab has no rows after the removal")
            #expect(app.hearts == [false, false], "no heart is on on the Listings tab")
        }
    }

    @Test func customerRemovesOnSavedAndItFails_seesTheRowBackAndAnAlert() async {
        let bookmark = makeBookmark(id: "1")
        let app = launch(.offline, sharing: AcceptanceApp.Stores(bookmarks: FailingBookmarkStore(bookmarks: [bookmark])))

        await app.observingBookmarks {
            await app.saved.remove(id: "1")

            #expect(app.savedIDs == ["1"], "the row is back on the Saved tab")
            #expect(app.router.alert == .error(BookmarksViewModel.Message.removeFailed), "the router holds the not-removed alert")
        }
    }

    // MARK: - Helpers

    private let now = Date()
    private let deCH = Locale(identifier: "de_CH")
    private let clock = TestClock()
    private let listingsURL = ListingsEndpoint.page(from: 0, size: ListingsService.pageSize).url(baseURL: ServiceURLs.listings)
    private let house = makeRemoteListing(id: "1", title: "Haus", price: 9_999_999)
    private let flat = makeRemoteListing(id: "2", title: "Maison", price: nil, street: nil)

    private var online: HTTPClientStub {
        HTTPClientStub([listingsURL: [.success(makeItemsJSON([house.json, flat.json]))]])
    }

    private func launch(
        _ client: HTTPClientStub,
        bookmarks: [Bookmark] = [],
        sharing stores: AcceptanceApp.Stores? = nil
    ) -> AcceptanceApp {
        let stores = stores ?? AcceptanceApp.Stores(bookmarks: InMemoryBookmarkStore(bookmarks: bookmarks.map(LocalBookmark.init(bookmark:))))
        return AcceptanceApp(client: client, stores: stores, today: LockIsolated(now), locale: deCH, clock: clock)
    }
}

private extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
