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
            try ListingsMapper.map(Data("invalid json".utf8), from: anyHTTPURLResponse())
        }
    }

    @Test func map_deliversNoItemsOn200WithEmptyResults() throws {
        let result = try ListingsMapper.map(makeItemsJSON([]), from: anyHTTPURLResponse())

        #expect(result == [])
    }

    @Test func map_deliversItemsOn200WithItems() throws {
        let house = makeListing(id: "1", title: "Haus", street: "Musterstrasse 999")
        let flat = makeListing(id: "2", title: "Maison", street: nil, postalCode: nil)

        let result = try ListingsMapper.map(makeItemsJSON([house.json, flat.json]), from: anyHTTPURLResponse())

        #expect(result == [house.model, flat.model])
    }

    @Test func map_readsTheTitleUnderThePrimaryLanguageKey() throws {
        let french = makeListing(title: "Maison moderne", primaryLanguage: "fr")

        let result = try ListingsMapper.map(makeItemsJSON([french.json]), from: anyHTTPURLResponse())

        #expect(result == [french.model])
    }

    @Test func map_fallsBackToAnyLanguageWhenThePrimaryBlockIsMissing() throws {
        let onlyGerman = makeListing(
            title: "Haus",
            primaryLanguage: "fr",
            attachments: [],
            languageBlocks: ["de": ["text": ["title": "Haus"]]]
        )

        let result = try ListingsMapper.map(makeItemsJSON([onlyGerman.json]), from: anyHTTPURLResponse())

        #expect(result == [onlyGerman.model])
    }

    @Test func map_picksTheFirstImageAttachmentSkippingDocuments() throws {
        let item = makeListing(attachments: [
            ("DOCUMENT", "https://img.example/brochure.pdf"),
            ("IMAGE", "https://img.example/first.jpg"),
            ("IMAGE", "https://img.example/second.jpg"),
        ])

        let result = try ListingsMapper.map(makeItemsJSON([item.json]), from: anyHTTPURLResponse())

        #expect(result == [item.model])
        #expect(result.first?.imageURL == URL(string: "https://img.example/first.jpg"))
    }

    @Test func map_deliversNoImageURLWhenThereIsNoImageAttachment() throws {
        let item = makeListing(attachments: [("DOCUMENT", "https://img.example/brochure.pdf")])

        let result = try ListingsMapper.map(makeItemsJSON([item.json]), from: anyHTTPURLResponse())

        #expect(result == [item.model])
        #expect(result.first?.imageURL == nil)
    }

    @Test func map_deliversNoImageURLWhenThereAreNoAttachments() throws {
        let item = makeListing(attachments: [])

        let result = try ListingsMapper.map(makeItemsJSON([item.json]), from: anyHTTPURLResponse())

        #expect(result == [item.model])
    }

    @Test func map_readsTheBuyPriceWithItsCurrency() throws {
        let house = makeListing(price: 9_999_999, priceKind: "buy", currency: "CHF")

        let result = try ListingsMapper.map(makeItemsJSON([house.json]), from: anyHTTPURLResponse())

        #expect(result == [house.model])
        #expect(result.first?.price == Price(amount: 9_999_999, currency: "CHF"))
    }

    @Test func map_readsTheRentPriceWhenThereIsNoBuyPrice() throws {
        let flat = makeListing(price: 1_250, priceKind: "rent", currency: "CHF")

        let result = try ListingsMapper.map(makeItemsJSON([flat.json]), from: anyHTTPURLResponse())

        #expect(result == [flat.model])
    }

    @Test func map_deliversNoPriceWhenThePriceBlockIsEmpty() throws {
        let item = makeListing(price: nil)

        let result = try ListingsMapper.map(makeItemsJSON([item.json]), from: anyHTTPURLResponse())

        #expect(result == [item.model])
        #expect(result.first?.price == nil)
    }

    @Test func map_deliversNoPriceWhenThereIsNoCurrency() throws {
        let item = makeListing(price: 100, currency: nil)

        let result = try ListingsMapper.map(makeItemsJSON([item.json]), from: anyHTTPURLResponse())

        #expect(result == [item.model])
        #expect(result.first?.price == nil)
    }

    @Test func map_decodesTheFifteenDigitPriceExactly() throws {
        let item = makeListing(price: Decimal(string: "999999999999999")!)

        let result = try ListingsMapper.map(makeItemsJSON([item.json]), from: anyHTTPURLResponse())

        #expect(result.first?.price?.amount == Decimal(string: "999999999999999"))
    }

    @Test func map_throwsWhenAnItemHasNoTitle() {
        let untitled = makeListing(languageBlocks: ["de": ["text": [:]]])

        #expect(throws: ListingsMapper.Error.invalidData) {
            try ListingsMapper.map(makeItemsJSON([untitled.json]), from: anyHTTPURLResponse())
        }
    }
}
