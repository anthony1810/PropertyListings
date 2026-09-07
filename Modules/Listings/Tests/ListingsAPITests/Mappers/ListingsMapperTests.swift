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
            languageBlocks: ["de": ["text": ["title": "Haus"]]]
        )

        let result = try ListingsMapper.map(makeItemsJSON([onlyGerman.json]), from: anyHTTPURLResponse())

        #expect(result == [onlyGerman.model])
    }

    @Test func map_throwsWhenAnItemHasNoTitle() {
        let untitled = makeListing(languageBlocks: ["de": ["text": [:]]])

        #expect(throws: ListingsMapper.Error.invalidData) {
            try ListingsMapper.map(makeItemsJSON([untitled.json]), from: anyHTTPURLResponse())
        }
    }
}
