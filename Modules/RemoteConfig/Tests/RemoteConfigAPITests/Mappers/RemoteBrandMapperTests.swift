import Foundation
import RemoteConfigFeature
import Testing
import TestSupport
@testable import RemoteConfigAPI

@Suite struct RemoteBrandMapperTests {
    @Test(arguments: [199, 201, 300, 400, 500])
    func map_throwsOnNonOKResponse(statusCode: Int) {
        #expect(throws: RemoteBrandMapper.Error.invalidData) {
            try RemoteBrandMapper.map(
                completeDocument,
                from: anyHTTPURLResponse(statusCode: statusCode)
            )
        }
    }

    @Test func map_throwsOnOKWithInvalidJSON() {
        #expect(throws: RemoteBrandMapper.Error.invalidData) {
            try RemoteBrandMapper.map(invalidJSON(), from: anyHTTPURLResponse())
        }
    }

    @Test func map_throwsOnADocumentMissingAField() {
        var incomplete = document
        incomplete["tabs"] = nil

        #expect(throws: RemoteBrandMapper.Error.invalidData) {
            try RemoteBrandMapper.map(json(incomplete), from: anyHTTPURLResponse())
        }
    }

    @Test func map_throwsOnADocumentWithAnUnusableHost() {
        var invalidHost = document
        invalidHost["listings"] = [
            "host": "", "pageSize": pageSize, "cacheMaxAgeInDays": cacheMaxAgeInDays,
        ]

        #expect(throws: RemoteBrandMapper.Error.invalidData) {
            try RemoteBrandMapper.map(json(invalidHost), from: anyHTTPURLResponse())
        }
    }

    @Test func map_deliversTheBrandOnACompleteDocument() throws {
        let brand = try RemoteBrandMapper.map(completeDocument, from: anyHTTPURLResponse())

        #expect(
            brand
                == RemoteBrand(
                    listingsHost: host,
                    listingsPageSize: pageSize,
                    listingsCacheMaxAgeInDays: cacheMaxAgeInDays,
                    defaultLanguage: defaultLanguage,
                    supportedLanguages: supportedLanguages,
                    tabs: tabs
                )
        )
    }

    // MARK: - Helpers

    private let host = anyURL()
    private let pageSize = 4
    private let cacheMaxAgeInDays = 3
    private let defaultLanguage = "vi"
    private let supportedLanguages = ["vi", "en"]
    private let tabs = ["listings", "settings"]

    private var document: [String: Any] {
        [
            "listings": [
                "host": host.absoluteString,
                "pageSize": pageSize,
                "cacheMaxAgeInDays": cacheMaxAgeInDays,
            ],
            "settings": [
                "defaultLanguage": defaultLanguage,
                "supportedLanguages": supportedLanguages,
            ],
            "tabs": tabs,
        ]
    }

    private var completeDocument: Data { json(document) }

    private func json(_ object: [String: Any]) -> Data {
        try! JSONSerialization.data(withJSONObject: object)
    }
}
