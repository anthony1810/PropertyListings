import Foundation
import ListingsAPI
import ListingsCache
import ListingsFeature
import Testing
import TestSupport
@testable import PropertyListings

struct ListingsServiceTests {
    @Test func loadListings_deliversRemoteListingsWhenOnline() async throws {
        let sut = makeSUT([url: [.success(listingsJSON, statusCode: 200)]])

        let listings = try await sut.loadListings()

        #expect(listings == [house.model, flat.model])
    }

    @Test func loadListings_failsWhenOffline() async {
        let sut = makeSUT([:])

        await #expect(throws: Error.self) {
            try await sut.loadListings()
        }
    }

    @Test func loadListings_cachesRemoteListingsWithTimestampWhenOnline() async throws {
        let store = InMemoryListingsStore()
        let sut = makeSUT([url: [.success(listingsJSON, statusCode: 200)]], store: store)

        _ = try await sut.loadListings()

        #expect(try await store.retrieve() == CachedListings(listings: [house.local, flat.local], timestamp: now))
    }

    @Test func loadListings_doesNotCacheWhenRemoteFails() async throws {
        let store = InMemoryListingsStore()
        let sut = makeSUT([url: [.success(Data("not json".utf8), statusCode: 200)]], store: store)

        _ = try? await sut.loadListings()

        #expect(try await store.retrieve() == nil)
    }

    // MARK: - Helpers

    private let now = Date()
    private let url = ListingsEndpoint.get.url(baseURL: anyURL())
    private let house = makeRemoteListing(id: "1", title: "Haus", price: 9_999_999)
    private let flat = makeRemoteListing(id: "2", title: "Maison", price: nil, street: nil)

    private var listingsJSON: Data { makeItemsJSON([house.json, flat.json]) }

    private func makeSUT(
        _ outcomes: [URL: [HTTPClientStub.Outcome]],
        store: InMemoryListingsStore = InMemoryListingsStore()
    ) -> ListingsService {
        ListingsService(
            httpClient: HTTPClientStub(outcomes),
            store: store,
            baseURL: anyURL(),
            currentDate: { [now] in now }
        )
    }
}
