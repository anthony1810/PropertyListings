import BookmarksPersistence
import Foundation
import ListingsAPI
import ListingsCache
import ListingsFeature
import ListingsPresentation
import SharedPresentation
import Testing
import TestSupport
@testable import PropertyListings

@MainActor
struct ListingsAcceptanceTests {
    init() {
        let start = Date()
        now = start
        today = LockIsolated(start)
    }

    // MARK: - Narrative 1, online customer

    @Test func customerOpensListings_seesTheLatestListingsFromRemote() async {
        let listings = launch(online).listings

        await listings.load()

        #expect(listings.rows.map(\.title) == ["Haus", "Maison"])
        #expect(listings.rows.map(\.imageURL) == [house.model.imageURL, flat.model.imageURL])
        #expect(listings.loadFailureMessage == nil)
    }

    @Test func customerOpensListings_seesSwissPricesAndPriceOnRequest() async {
        let listings = launch(online).listings

        await listings.load()

        #expect(listings.rows.map(\.priceText) == [chf("9'999'999"), PriceFormatter.onRequest(deCH)])
    }

    @Test func customerOpensListings_seesTheAddressWithoutAStreetAsPostalCodeAndLocality() async {
        let listings = launch(online).listings

        await listings.load()

        #expect(listings.rows.map(\.addressText) == ["Musterstrasse 999, 2406 La Brévine", "2406 La Brévine"])
    }

    @Test(arguments: [HTTPClientStub.Outcome.success(invalidJSON()), .failure])
    func customerOpensListings_seesTheErrorWithRetryWhenRemoteFailsAndThereIsNoCache(outcome: HTTPClientStub.Outcome) async {
        let listings = launch(HTTPClientStub([listingsURL: [outcome]])).listings

        await listings.load()

        #expect(listings.rows == [])
        #expect(listings.loadFailureMessage == ListingsViewModel.Message.listingsFailed(deCH))
    }

    @Test func customerRetriesAfterAFailure_seesTheListings() async {
        let listings = launch(HTTPClientStub([listingsURL: [.failure, .success(listingsJSON)]])).listings
        await listings.load()

        await listings.load()

        #expect(listings.rows.map(\.title) == ["Haus", "Maison"])
        #expect(listings.loadFailureMessage == nil)
    }

    @Test func customerPullsToRefreshAndItFails_keepsTheListFromTheFreshCacheWithoutAnAlert() async {
        let app = launch(HTTPClientStub([listingsURL: [.success(listingsJSON), .failure]]))
        let listings = app.listings
        await listings.load()

        await listings.load()

        #expect(listings.rows.map(\.title) == ["Haus", "Maison"])
        #expect(listings.loadFailureMessage == nil)
        #expect(app.router.alert == nil)
    }

    @Test func customerPullsToRefreshAfterSevenDaysAndItFails_keepsTheListAndSeesAnAlert() async {
        let app = launch(HTTPClientStub([listingsURL: [.success(listingsJSON), .failure]]))
        let listings = app.listings
        await listings.load()
        today.setValue(now.adding(days: 7))

        await listings.load()

        #expect(listings.rows.map(\.title) == ["Haus", "Maison"])
        #expect(listings.loadFailureMessage == nil)
        #expect(app.router.alert == .error(ListingsViewModel.Message.listingsFailed(deCH)))
    }

    @Test func customerScrollsToTheEnd_seesTheNextPageAppended() async {
        let listings = launch(twoPages).listings
        await listings.load()

        await listings.loadMore()

        #expect(listings.rows.map(\.title) == ["Haus", "Maison", "Chalet"])
        #expect(listings.canLoadMore == false)
    }

    @Test func customerScrollsToTheEndAndItFails_keepsTheListAndSeesAnAlert() async {
        let app = launch(HTTPClientStub([firstPageURL: [.success(firstPageJSON)]]))
        let listings = app.listings
        await listings.load()

        await listings.loadMore()

        #expect(listings.rows.map(\.title) == ["Haus", "Maison"])
        #expect(app.router.alert == .error(ListingsViewModel.Message.listingsFailed(deCH)))
    }

    // MARK: - Narrative 3, liking a listing

    @Test func customerLikesAListing_seesTheHeartFilledAtOnce() async {
        let app = launch(online)
        await app.listings.load()

        app.listings.toggleBookmark(id: house.model.id)

        #expect(app.hearts == [true, false], "the first row's heart is on before anything is written")
    }

    @Test func customerLikesAListing_seesItStillLikedAfterRelaunch() async {
        let firstLaunch = launch(online)
        await firstLaunch.listings.load()
        await firstLaunch.like(house.model)
        let secondLaunch = launch(online, sharing: firstLaunch.stores)
        await secondLaunch.listings.load()

        await secondLaunch.observingBookmarks {
            #expect(secondLaunch.hearts == [true, false], "the first row's heart is on after the relaunch")
        }
    }

    @Test func customerUnlikesAListing_seesItClearedAfterRelaunch() async {
        let firstLaunch = launch(online)
        await firstLaunch.listings.load()
        await firstLaunch.like(house.model)
        await firstLaunch.unlike(house.model)
        let secondLaunch = launch(online, sharing: firstLaunch.stores)
        await secondLaunch.listings.load()

        await secondLaunch.observingBookmarks {
            #expect(secondLaunch.hearts == [false, false], "no heart is on after the relaunch")
        }
    }

    @Test func customerLikesAListingAndSavingFails_seesTheHeartRevertedAndAnAlert() async {
        let app = launch(online, sharing: AcceptanceApp.Stores(bookmarks: FailingBookmarkStore()))
        await app.listings.load()

        await app.like(house.model)

        #expect(app.hearts == [false, false], "the first row's heart is off again")
        #expect(app.router.alert == .error(ListingsViewModel.Message.bookmarkNotSaved(deCH)), "the router holds the not-saved alert")
    }

    // MARK: - Narrative 2, offline customer

    @Test func offlineCustomer_seesTheListingsCachedByAnEarlierVisit() async {
        let onlineLaunch = launch(online)
        await onlineLaunch.listings.load()
        let offlineListings = launch(.offline, sharing: onlineLaunch.stores).listings
        let onlineListings = onlineLaunch.listings

        await offlineListings.load()

        #expect(offlineListings.rows == onlineListings.rows)
        #expect(offlineListings.loadFailureMessage == nil)
    }

    @Test func offlineCustomer_seesTheErrorWithRetryWhenTheCacheIsSevenDaysOld() async {
        let listings = launch(.offline, sharing: AcceptanceApp.Stores(listings: InMemoryListingsStore(cache: expiredCache))).listings

        await listings.load()

        #expect(listings.rows == [])
        #expect(listings.loadFailureMessage == ListingsViewModel.Message.listingsFailed(deCH))
    }

    @Test func offlineCustomer_seesTheErrorWithRetryWhenThereIsNoCache() async {
        let listings = launch(.offline).listings

        await listings.load()

        #expect(listings.rows == [])
        #expect(listings.loadFailureMessage == ListingsViewModel.Message.listingsFailed(deCH))
    }

    @Test func appLaunch_deletesAnExpiredCache() async throws {
        let app = launch(.offline, sharing: AcceptanceApp.Stores(listings: InMemoryListingsStore(cache: expiredCache)))

        await app.composition.validateCache()

        #expect(try await app.stores.listings.retrieve() == nil, "the expired cache is gone from the store")
    }

    // MARK: - Helpers

    private let now: Date
    private let today: LockIsolated<Date>
    private let clock = TestClock()
    private let deCH = Locale(identifier: "de_CH")
    private let listingsURL = ListingsEndpoint.page(from: 0, size: 5).url(baseURL: ServiceURLs.listings)
    private let house = makeRemoteListing(
        id: "1",
        title: "Haus",
        price: 9_999_999,
        street: "Musterstrasse 999",
        postalCode: "2406",
        locality: "La Brévine"
    )
    private let flat = makeRemoteListing(
        id: "2",
        title: "Maison",
        price: nil,
        street: nil,
        postalCode: "2406",
        locality: "La Brévine"
    )

    private let chalet = makeRemoteListing(id: "3", title: "Chalet")
    private let firstPageURL = ListingsEndpoint.page(from: 0, size: ListingsService.pageSize).url(baseURL: ServiceURLs.listings)
    private let secondPageURL = ListingsEndpoint.page(from: 2, size: ListingsService.pageSize).url(baseURL: ServiceURLs.listings)

    private var listingsJSON: Data { makeItemsJSON([house.json, flat.json]) }
    private var firstPageJSON: Data { makeItemsJSON([house.json, flat.json], from: 0, size: 2, total: 3, maxFrom: 2) }
    private var secondPageJSON: Data { makeItemsJSON([chalet.json], from: 2, size: 2, total: 3, maxFrom: 2) }

    private var twoPages: HTTPClientStub {
        HTTPClientStub([firstPageURL: [.success(firstPageJSON)], secondPageURL: [.success(secondPageJSON)]])
    }

    private var online: HTTPClientStub {
        HTTPClientStub([listingsURL: [.success(listingsJSON)]])
    }

    private var expiredCache: CachedListings {
        CachedListings(listings: [house.local], timestamp: now.adding(days: -7))
    }

    private func chf(_ number: String) -> String {
        "CHF\u{00A0}" + number.replacingOccurrences(of: "'", with: deCH.groupingSeparator ?? "'")
    }

    private func launch(_ client: HTTPClientStub, sharing stores: AcceptanceApp.Stores = AcceptanceApp.Stores()) -> AcceptanceApp {
        AcceptanceApp(client: client, stores: stores, today: today, locale: deCH, clock: clock)
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
