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

    // MARK: - Helpers

    private let url = ListingsEndpoint.get.url(baseURL: anyURL())
    private let house = makeRemoteListing(id: "1", title: "Haus", price: 9_999_999)
    private let flat = makeRemoteListing(id: "2", title: "Maison", price: nil, street: nil)

    private var listingsJSON: Data { makeItemsJSON([house.json, flat.json]) }

    private func makeSUT(_ outcomes: [URL: [HTTPClientStub.Outcome]]) -> ListingsService {
        ListingsService(httpClient: HTTPClientStub(outcomes), baseURL: anyURL())
    }
}
