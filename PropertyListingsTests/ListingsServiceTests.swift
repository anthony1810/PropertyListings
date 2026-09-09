import Foundation
import ListingsAPI
import ListingsCache
import ListingsFeature
import Testing
import TestSupport
@testable import PropertyListings

struct ListingsServiceTests {
    // MARK: - Load listings

    @Test func loadListings_deliversRemoteListingsWhenOnline() async throws {
        let sut = makeSUT(client: online)

        let listings = try await sut.loadListings()

        #expect(listings.items == [house.model, flat.model])
    }

    // MARK: - Paging

    @Test func loadListings_requestsTheFirstPageOfFiveAndOffersLoadMoreWhenMoreExist() async throws {
        let sut = makeSUT(client: HTTPClientStub([firstPageURL: [.success(firstPageJSON)]]))

        let page = try await sut.loadListings()

        #expect(page.items == [house.model, flat.model])
        #expect(page.loadMore != nil)
    }

    @Test func loadListings_offersNoLoadMoreOnTheLastPage() async throws {
        let sut = makeSUT(client: online)

        let page = try await sut.loadListings()

        #expect(page.loadMore == nil)
    }

    @Test func loadMore_appendsTheNextPageAndCachesTheUnion() async throws {
        let store = InMemoryListingsStore()
        let sut = makeSUT(client: twoPages, store: store)
        let firstPage = try await sut.loadListings()

        let secondPage = try await firstPage.loadMore?()

        #expect(secondPage?.items == [house.model, flat.model, chalet.model])
        #expect(secondPage?.loadMore == nil)
        #expect(try await store.retrieve() == CachedListings(listings: [house.local, flat.local, chalet.local], timestamp: now))
    }

    @Test func loadMore_failsWhenOfflineWithoutTouchingTheCache() async throws {
        let store = InMemoryListingsStore()
        let sut = makeSUT(client: HTTPClientStub([firstPageURL: [.success(firstPageJSON)]]), store: store)
        let firstPage = try await sut.loadListings()

        await #expect(throws: Error.self) {
            try await firstPage.loadMore?()
        }
        #expect(try await store.retrieve() == CachedListings(listings: [house.local, flat.local], timestamp: now))
    }

    @Test func loadListings_offersNoLoadMoreWhenServingTheCacheOffline() async throws {
        let sut = makeSUT(client: .offline, store: InMemoryListingsStore(cache: freshCache))

        let page = try await sut.loadListings()

        #expect(page.items == [house.model])
        #expect(page.loadMore == nil)
    }

    @Test func loadListings_cachesRemoteListingsWithTimestampWhenOnline() async throws {
        let store = InMemoryListingsStore()
        let sut = makeSUT(client: online, store: store)

        _ = try await sut.loadListings()

        #expect(try await store.retrieve() == CachedListings(listings: [house.local, flat.local], timestamp: now))
    }

    @Test func loadListings_doesNotCacheWhenRemoteIsMalformed() async throws {
        let store = InMemoryListingsStore()
        let sut = makeSUT(client: malformed, store: store)

        _ = try? await sut.loadListings()

        #expect(try await store.retrieve() == nil)
    }

    @Test func loadListings_throwsCacheMissWhenOfflineWithNoCache() async {
        let sut = makeSUT(client: .offline)

        await #expect(throws: LocalListingsLoader.Error.cacheMiss) {
            try await sut.loadListings()
        }
    }

    @Test func loadListings_throwsCacheMissWhenOfflineWithExpiredCache() async {
        let sut = makeSUT(client: .offline, store: InMemoryListingsStore(cache: expiredCache))

        await #expect(throws: LocalListingsLoader.Error.cacheMiss) {
            try await sut.loadListings()
        }
    }

    @Test func loadListings_deliversCachedListingsWhenOfflineWithFreshCache() async throws {
        let sut = makeSUT(client: .offline, store: InMemoryListingsStore(cache: freshCache))

        let listings = try await sut.loadListings()

        #expect(listings.items == [house.model])
    }

    @Test func loadListings_deliversListingsCachedByAnEarlierOnlineLoadWhenOffline() async throws {
        let store = InMemoryListingsStore()
        let onlineSUT = makeSUT(client: online, store: store)
        _ = try await onlineSUT.loadListings()
        let offlineSUT = makeSUT(client: .offline, store: store)

        let listings = try await offlineSUT.loadListings()

        #expect(listings.items == [house.model, flat.model])
    }

    @Test func loadListings_keepsServingTheCacheWhenRemoteIsMalformed() async throws {
        let sut = makeSUT(client: malformed, store: InMemoryListingsStore(cache: freshCache))

        let listings = try await sut.loadListings()

        #expect(listings.items == [house.model])
    }

    // MARK: - Validate cache

    @Test func validateCache_deletesExpiredCache() async throws {
        let store = InMemoryListingsStore(cache: expiredCache)
        let sut = makeSUT(client: .offline, store: store)

        await sut.validateCache()

        #expect(try await store.retrieve() == nil)
    }

    @Test func validateCache_keepsFreshCache() async throws {
        let store = InMemoryListingsStore(cache: freshCache)
        let sut = makeSUT(client: .offline, store: store)

        await sut.validateCache()

        #expect(try await store.retrieve() == freshCache)
    }

    // MARK: - Helpers

    private let now = Date()
    private let url = ListingsEndpoint.page(from: 0, size: ListingsService.pageSize).url(baseURL: anyURL())
    private let firstPageURL = ListingsEndpoint.page(from: 0, size: ListingsService.pageSize).url(baseURL: anyURL())
    private let secondPageURL = ListingsEndpoint.page(from: 2, size: ListingsService.pageSize).url(baseURL: anyURL())
    private let house = makeRemoteListing(id: "1", title: "Haus", price: 9_999_999)
    private let flat = makeRemoteListing(id: "2", title: "Maison", price: nil, street: nil)
    private let chalet = makeRemoteListing(id: "3", title: "Chalet")

    private var firstPageJSON: Data {
        makeItemsJSON([house.json, flat.json], from: 0, size: 2, total: 3, maxFrom: 2)
    }

    private var secondPageJSON: Data {
        makeItemsJSON([chalet.json], from: 2, size: 2, total: 3, maxFrom: 2)
    }

    private var twoPages: HTTPClientStub {
        HTTPClientStub([firstPageURL: [.success(firstPageJSON)], secondPageURL: [.success(secondPageJSON)]])
    }

    private var online: HTTPClientStub {
        HTTPClientStub([url: [.success(makeItemsJSON([house.json, flat.json]))]])
    }

    private var malformed: HTTPClientStub {
        HTTPClientStub([url: [.success(invalidJSON())]])
    }

    private var freshCache: CachedListings {
        CachedListings(listings: [house.local], timestamp: now.adding(days: -7).adding(seconds: 1))
    }

    private var expiredCache: CachedListings {
        CachedListings(listings: [house.local], timestamp: now.adding(days: -7))
    }

    private func makeSUT(
        client: HTTPClientStub,
        store: InMemoryListingsStore = InMemoryListingsStore()
    ) -> ListingsService {
        ListingsService(
            httpClient: client,
            store: store,
            baseURL: anyURL(),
            currentDate: { [now] in now }
        )
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
