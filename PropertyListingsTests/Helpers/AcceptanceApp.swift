import BookmarksFeature
import BookmarksPersistence
import BookmarksPresentation
import Foundation
import ListingsCache
import ListingsFeature
import ListingsPresentation
import SettingsFeature
import SettingsPersistence
import SettingsPresentation
import TestSupport
@testable import PropertyListings

@MainActor
struct AcceptanceApp {
    struct Stores {
        let listings: InMemoryListingsStore
        let bookmarks: BookmarkStore
        let settings: SettingsStore

        init(
            listings: InMemoryListingsStore = InMemoryListingsStore(),
            bookmarks: BookmarkStore = InMemoryBookmarkStore(),
            settings: SettingsStore = InMemorySettingsStore()
        ) {
            self.listings = listings
            self.bookmarks = bookmarks
            self.settings = settings
        }
    }

    let stores: Stores
    let composition: AppComposition
    let listings: ListingsViewModel
    let saved: BookmarksViewModel
    let settings: SettingsViewModel

    private let clock: TestClock<Duration>

    init(
        client: HTTPClientStub,
        stores: Stores,
        today: LockIsolated<Date>,
        locale: Locale,
        clock: TestClock<Duration>
    ) {
        self.stores = stores
        self.clock = clock
        composition = AppComposition(
            httpClient: client,
            listingsStore: stores.listings,
            bookmarkStore: stores.bookmarks,
            settingsStore: stores.settings,
            defaultSettings: Settings(appearance: .system, language: .german),
            currentDate: { [today] in today.value },
            locale: locale,
            clock: clock
        )
        listings = composition.listingsViewModel
        saved = composition.bookmarksViewModel
        settings = composition.settingsViewModel
    }

    var router: AppRouter { composition.router }
    var hearts: [Bool] { listings.rows.map(\.isBookmarked) }
    var titles: [String] { listings.rows.map(\.title) }
    var savedIDs: [String] { saved.rows.map(\.id) }

    func like(_ listing: Listing) async {
        await toggle(listing)
    }

    func unlike(_ listing: Listing) async {
        await toggle(listing)
    }

    func applyingSettings(_ body: () async -> Void) async {
        await withMainSerialExecutor {
            let settingsObservation = Task { await settings.observe() }
            let rootObservation = Task { await composition.observeSettings() }
            await Task.megaYield()
            await body()
            await Task.megaYield()
            await settingsObservation.cancelAndWait()
            await rootObservation.cancelAndWait()
        }
    }

    func observingBookmarks(_ body: () async -> Void) async {
        await withMainSerialExecutor {
            let listingsObservation = Task { await listings.observeBookmarks() }
            let savedObservation = Task { await saved.observe() }
            await Task.megaYield()
            await body()
            await listingsObservation.cancelAndWait()
            await savedObservation.cancelAndWait()
        }
    }

    private func toggle(_ listing: Listing) async {
        await withMainSerialExecutor {
            listings.toggleBookmark(id: listing.id)
            await clock.advance(by: ListingsViewModel.toggleDebounce)
            await Task.megaYield()
        }
    }
}
