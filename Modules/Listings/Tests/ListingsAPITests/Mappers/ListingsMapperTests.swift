import Foundation
import ListingsFeature
import Testing
import TestSupport
@testable import ListingsAPI

@Suite struct ListingsMapperTests {
    @Test(arguments: [199, 201, 300, 400, 500])
    func map_throwsOnNon200Response(statusCode: Int) {
        #expect(throws: ListingsMapper.Error.invalidData) {
            try ListingsMapper.map(makeItemsJSON([]), from: anyHTTPURLResponse(statusCode: statusCode))
        }
    }

    @Test func map_throwsOn200WithInvalidJSON() {
        #expect(throws: ListingsMapper.Error.invalidData) {
            try ListingsMapper.map(invalidJSON(), from: anyHTTPURLResponse())
        }
    }

    @Test func map_deliversNoItemsOn200WithEmptyResults() throws {
        let result = try ListingsMapper.map(makeItemsJSON([]), from: anyHTTPURLResponse())

        #expect(result.listings == [])
    }

    @Test func map_deliversItemsOn200WithItems() throws {
        let house = makeRemoteListing(id: "1", title: "Haus", street: "Musterstrasse 999")
        let flat = makeRemoteListing(id: "2", title: "Maison", street: nil, postalCode: nil)

        let result = try ListingsMapper.map(makeItemsJSON([house.json, flat.json]), from: anyHTTPURLResponse())

        #expect(result.listings == [house.model, flat.model])
    }

    @Test func map_readsTheTitleUnderThePrimaryLanguageKey() throws {
        let french = makeRemoteListing(title: "Maison moderne", primaryLanguage: "fr")

        let result = try ListingsMapper.map(makeItemsJSON([french.json]), from: anyHTTPURLResponse())

        #expect(result.listings == [french.model])
    }

    @Test func map_fallsBackToAnyLanguageWhenThePrimaryBlockIsMissing() throws {
        let onlyGerman = makeRemoteListing(
            title: "Haus",
            primaryLanguage: "fr",
            attachments: [],
            languageBlocks: ["de": ["text": ["title": "Haus"]]]
        )

        let result = try ListingsMapper.map(makeItemsJSON([onlyGerman.json]), from: anyHTTPURLResponse())

        #expect(result.listings == [onlyGerman.model])
    }

    @Test func map_picksTheFirstImageAttachmentSkippingDocuments() throws {
        let item = makeRemoteListing(attachments: [
            ("DOCUMENT", "https://img.example/brochure.pdf"),
            ("IMAGE", "https://img.example/first.jpg"),
            ("IMAGE", "https://img.example/second.jpg"),
        ])

        let result = try ListingsMapper.map(makeItemsJSON([item.json]), from: anyHTTPURLResponse())

        #expect(result.listings == [item.model])
        #expect(result.listings.first?.imageURL == URL(string: "https://img.example/first.jpg"))
    }

    @Test func map_deliversNoImageURLWhenThereIsNoImageAttachment() throws {
        let item = makeRemoteListing(attachments: [("DOCUMENT", "https://img.example/brochure.pdf")])

        let result = try ListingsMapper.map(makeItemsJSON([item.json]), from: anyHTTPURLResponse())

        #expect(result.listings == [item.model])
        #expect(result.listings.first?.imageURL == nil)
    }

    @Test func map_deliversNoImageURLWhenThereAreNoAttachments() throws {
        let item = makeRemoteListing(attachments: [])

        let result = try ListingsMapper.map(makeItemsJSON([item.json]), from: anyHTTPURLResponse())

        #expect(result.listings == [item.model])
    }

    @Test func map_readsTheBuyPriceWithItsCurrency() throws {
        let house = makeRemoteListing(price: 9_999_999, priceKind: "buy", currency: "CHF")

        let result = try ListingsMapper.map(makeItemsJSON([house.json]), from: anyHTTPURLResponse())

        #expect(result.listings == [house.model])
        #expect(result.listings.first?.price == Price(amount: 9_999_999, currency: "CHF"))
    }

    @Test func map_readsTheRentPriceWhenThereIsNoBuyPrice() throws {
        let flat = makeRemoteListing(price: 1_250, priceKind: "rent", currency: "CHF")

        let result = try ListingsMapper.map(makeItemsJSON([flat.json]), from: anyHTTPURLResponse())

        #expect(result.listings == [flat.model])
    }

    @Test func map_deliversNoPriceWhenThePriceBlockIsEmpty() throws {
        let item = makeRemoteListing(price: nil)

        let result = try ListingsMapper.map(makeItemsJSON([item.json]), from: anyHTTPURLResponse())

        #expect(result.listings == [item.model])
        #expect(result.listings.first?.price == nil)
    }

    @Test func map_deliversNoPriceWhenThereIsNoCurrency() throws {
        let item = makeRemoteListing(price: 100, currency: nil)

        let result = try ListingsMapper.map(makeItemsJSON([item.json]), from: anyHTTPURLResponse())

        #expect(result.listings == [item.model])
        #expect(result.listings.first?.price == nil)
    }

    @Test func map_decodesTheFifteenDigitPriceExactly() throws {
        let item = makeRemoteListing(price: Decimal(string: "999999999999999")!)

        let result = try ListingsMapper.map(makeItemsJSON([item.json]), from: anyHTTPURLResponse())

        #expect(result.listings.first?.price?.amount == Decimal(string: "999999999999999"))
    }

    @Test func map_deliversTheEnvelopeFields() throws {
        let item = makeRemoteListing()

        let result = try ListingsMapper.map(
            makeItemsJSON([item.json], from: 5, size: 5, total: 12, maxFrom: 10),
            from: anyHTTPURLResponse()
        )

        #expect(result == ListingsPage(listings: [item.model], from: 5, size: 5, total: 12, maxFrom: 10))
    }

    @Test func map_decodesTheRealPayload() throws {
        let result = try ListingsMapper.map(try Fixture.realPayload.data, from: anyHTTPURLResponse())

        #expect(result.listings.count == 9)
        #expect((result.from, result.size, result.total, result.maxFrom) == (0, 100, 9, 0))
        #expect(result.listings.first == Listing(
            id: "104123262",
            title: "Luxuriöses Einfamilienhaus mit Pool - Musterinserat",
            price: Price(amount: 9_999_999, currency: "CHF"),
            address: Address(street: "Musterstrasse 999", postalCode: "2406", locality: "La Brévine"),
            imageURL: URL(string: "https://media2.homegate.ch/listings/heia/104123262/image/6b53db714891bfe2321cc3a6d4af76e1.jpg")
        ))
        #expect(result.listings[6] == Listing(
            id: "3001697853",
            title: "Test Homegate",
            price: Price(amount: Decimal(string: "999999999999999")!, currency: "CHF"),
            address: Address(street: nil, postalCode: "2406", locality: "La Brévine"),
            imageURL: URL(string: "https://media2.homegate.ch/listings/heiasub3/3001697853/image/dbbad78b2e834742a70b6c35a0478e2c.jpg")
        ))
    }

    @Test func map_throwsWhenAnItemHasNoTitle() {
        let untitled = makeRemoteListing(languageBlocks: ["de": ["text": [:]]])

        #expect(throws: ListingsMapper.Error.invalidData) {
            try ListingsMapper.map(makeItemsJSON([untitled.json]), from: anyHTTPURLResponse())
        }
    }
}
