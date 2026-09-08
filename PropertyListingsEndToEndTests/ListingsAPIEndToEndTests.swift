import Foundation
import HTTPClientLive
import ListingsAPI
import ListingsFeature
import Testing

@Suite struct ListingsAPIEndToEndTests {
    @Test func get_deliversTheFixedListingsFromTheLiveEndpoint() async throws {
        let listings = try await getListings()

        #expect(listings.count == 9)
        #expect(listings.first == Listing(
            id: "104123262",
            title: "Luxuriöses Einfamilienhaus mit Pool - Musterinserat",
            price: Price(amount: 9_999_999, currency: "CHF"),
            address: Address(street: "Musterstrasse 999", postalCode: "2406", locality: "La Brévine"),
            imageURL: URL(string: "https://media2.homegate.ch/listings/heia/104123262/image/6b53db714891bfe2321cc3a6d4af76e1.jpg")
        ))
    }

    private func getListings() async throws -> [Listing] {
        let baseURL = URL(string: "https://private-9f1bb1-homegate3.apiary-mock.com")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let (data, response) = try await client.get(from: ListingsEndpoint.page(from: 0, size: 5).url(baseURL: baseURL))
        return try ListingsMapper.map(data, from: response)
    }
}
