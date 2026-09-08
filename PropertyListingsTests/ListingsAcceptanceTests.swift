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
        let (listings, _) = makeApp(client: online)

        await listings.load()

        #expect(listings.rows.map(\.title) == ["Haus", "Maison"])
        #expect(listings.rows.map(\.imageURL) == [house.model.imageURL, flat.model.imageURL])
        #expect(listings.loadFailureMessage == nil)
    }

    @Test func customerOpensListings_seesSwissPricesAndPriceOnRequest() async {
        let (listings, _) = makeApp(client: online)

        await listings.load()

        #expect(listings.rows.map(\.priceText) == [chf("9'999'999"), PriceFormatter.onRequest])
    }

    @Test func customerOpensListings_seesTheAddressWithoutAStreetAsPostalCodeAndLocality() async {
        let (listings, _) = makeApp(client: online)

        await listings.load()

        #expect(listings.rows.map(\.addressText) == ["Musterstrasse 999, 2406 La Brévine", "2406 La Brévine"])
    }

    @Test(arguments: [HTTPClientStub.Outcome.success(invalidJSON()), .failure])
    func customerOpensListings_seesTheErrorWithRetryWhenRemoteFailsAndThereIsNoCache(outcome: HTTPClientStub.Outcome) async {
        let (listings, _) = makeApp(client: HTTPClientStub([listingsURL: [outcome]]))

        await listings.load()

        #expect(listings.rows == [])
        #expect(listings.loadFailureMessage == ListingsViewModel.Message.listingsFailed)
    }

    @Test func customerRetriesAfterAFailure_seesTheListings() async {
        let (listings, _) = makeApp(client: HTTPClientStub([listingsURL: [.failure, .success(listingsJSON)]]))
        await listings.load()

        await listings.load()

        #expect(listings.rows.map(\.title) == ["Haus", "Maison"])
        #expect(listings.loadFailureMessage == nil)
    }

    @Test func customerPullsToRefreshAndItFails_keepsTheListFromTheFreshCacheWithoutAnAlert() async {
        let (listings, app) = makeApp(client: HTTPClientStub([listingsURL: [.success(listingsJSON), .failure]]))
        await listings.load()

        await listings.load()

        #expect(listings.rows.map(\.title) == ["Haus", "Maison"])
        #expect(listings.loadFailureMessage == nil)
        #expect(app.router.alert == nil)
    }

    @Test func customerPullsToRefreshAfterSevenDaysAndItFails_keepsTheListAndSeesAnAlert() async {
        let (listings, app) = makeApp(client: HTTPClientStub([listingsURL: [.success(listingsJSON), .failure]]))
        await listings.load()
        today.setValue(now.adding(days: 7))

        await listings.load()

        #expect(listings.rows.map(\.title) == ["Haus", "Maison"])
        #expect(listings.loadFailureMessage == nil)
        #expect(app.router.alert == .error(ListingsViewModel.Message.listingsFailed))
    }

    // MARK: - Narrative 2, offline customer

    @Test func offlineCustomer_seesTheListingsCachedByAnEarlierVisit() async {
        let sharedStore = InMemoryListingsStore()
        let (onlineListings, _) = makeApp(client: online, listingsStore: sharedStore)
        await onlineListings.load()
        let (offlineListings, _) = makeApp(client: .offline, listingsStore: sharedStore)

        await offlineListings.load()

        #expect(offlineListings.rows == onlineListings.rows)
        #expect(offlineListings.loadFailureMessage == nil)
    }

    @Test func offlineCustomer_seesTheErrorWithRetryWhenTheCacheIsSevenDaysOld() async {
        let (listings, _) = makeApp(client: .offline, listingsStore: InMemoryListingsStore(cache: expiredCache))

        await listings.load()

        #expect(listings.rows == [])
        #expect(listings.loadFailureMessage == ListingsViewModel.Message.listingsFailed)
    }

    @Test func offlineCustomer_seesTheErrorWithRetryWhenThereIsNoCache() async {
        let (listings, _) = makeApp(client: .offline)

        await listings.load()

        #expect(listings.rows == [])
        #expect(listings.loadFailureMessage == ListingsViewModel.Message.listingsFailed)
    }

    @Test func appLaunch_deletesAnExpiredCache() async throws {
        let store = InMemoryListingsStore(cache: expiredCache)
        let (_, app) = makeApp(client: .offline, listingsStore: store)

        await app.validateCache()

        #expect(try await store.retrieve() == nil)
    }

    // MARK: - Helpers

    private let now: Date
    private let today: LockIsolated<Date>
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

    private var listingsJSON: Data { makeItemsJSON([house.json, flat.json]) }

    private var online: HTTPClientStub {
        HTTPClientStub([listingsURL: [.success(listingsJSON)]])
    }

    private var expiredCache: CachedListings {
        CachedListings(listings: [house.local], timestamp: now.adding(days: -7))
    }

    private func chf(_ number: String) -> String {
        "CHF\u{00A0}" + number.replacingOccurrences(of: "'", with: deCH.groupingSeparator ?? "'")
    }

    private func makeApp(
        client: HTTPClientStub,
        listingsStore: InMemoryListingsStore = InMemoryListingsStore()
    ) -> (listings: ListingsViewModel, app: AppComposition) {
        let app = AppComposition(
            httpClient: client,
            listingsStore: listingsStore,
            currentDate: { [today] in today.value },
            locale: deCH
        )
        return (app.makeListingsViewModel(), app)
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
