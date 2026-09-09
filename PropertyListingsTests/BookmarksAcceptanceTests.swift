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
        await withMainSerialExecutor {
            let older = makeBookmark(id: "1", title: "Haus", savedAt: now.adding(seconds: -60))
            let newer = makeBookmark(id: "2", title: "Chalet", savedAt: now)
            let (saved, _) = makeApp(client: .offline, bookmarks: [older, newer])
            let observation = Task { await saved.observe() }

            await Task.megaYield()

            #expect(saved.rows == [
                BookmarkRowMapper.map(newer, locale: deCH),
                BookmarkRowMapper.map(older, locale: deCH),
            ])
            await observation.cancelAndWait()
        }
    }

    @Test func customerOpensSavedWithNoLikes_seesNothingToShow() async {
        await withMainSerialExecutor {
            let (saved, _) = makeApp(client: .offline)
            let observation = Task { await saved.observe() }

            await Task.megaYield()

            #expect(saved.rows == [])
            await observation.cancelAndWait()
        }
    }

    @Test func customerLikesOnListings_seesItAppearOnSaved() async {
        await withMainSerialExecutor {
            let (saved, app) = makeApp(client: online)
            let listings = app.makeListingsViewModel()
            await listings.load()
            let observation = Task { await saved.observe() }
            await Task.megaYield()

            listings.toggleBookmark(id: house.model.id)
            await clock.advance(by: ListingsViewModel.toggleDebounce)
            await Task.megaYield()

            #expect(saved.rows.map(\.id) == [house.model.id])
            await observation.cancelAndWait()
        }
    }

    // MARK: - Narrative 3, removing on Saved

    @Test func customerRemovesOnSaved_seesTheRowLeaveAndTheHeartClearOnListings() async {
        await withMainSerialExecutor {
            let (saved, app) = makeApp(client: online, bookmarks: [Bookmark(listing: house.model, savedAt: now)])
            let listings = app.makeListingsViewModel()
            await listings.load()
            let savedObservation = Task { await saved.observe() }
            let listingsObservation = Task { await listings.observeBookmarks() }
            await Task.megaYield()

            await saved.remove(id: house.model.id)
            await Task.megaYield()

            #expect(saved.rows == [])
            #expect(listings.rows.map(\.isBookmarked) == [false, false])
            await savedObservation.cancelAndWait()
            await listingsObservation.cancelAndWait()
        }
    }

    @Test func customerRemovesOnSavedAndItFails_seesTheRowBackAndAnAlert() async {
        await withMainSerialExecutor {
            let bookmark = makeBookmark(id: "1")
            let (saved, app) = makeApp(client: .offline, bookmarkStore: FailingBookmarkStore(bookmarks: [bookmark]))
            let observation = Task { await saved.observe() }
            await Task.megaYield()

            await saved.remove(id: "1")

            #expect(saved.rows.map(\.id) == ["1"])
            #expect(app.router.alert == .error(BookmarksViewModel.Message.removeFailed))
            await observation.cancelAndWait()
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

    private func makeApp(
        client: HTTPClientStub,
        bookmarks: [Bookmark] = [],
        bookmarkStore: BookmarkStore? = nil
    ) -> (saved: BookmarksViewModel, app: AppComposition) {
        let app = AppComposition(
            httpClient: client,
            listingsStore: InMemoryListingsStore(),
            bookmarkStore: bookmarkStore ?? InMemoryBookmarkStore(bookmarks: bookmarks.map(LocalBookmark.init(bookmark:))),
            currentDate: { [now] in now },
            locale: deCH,
            clock: clock
        )
        return (app.makeBookmarksViewModel(), app)
    }
}

private extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
