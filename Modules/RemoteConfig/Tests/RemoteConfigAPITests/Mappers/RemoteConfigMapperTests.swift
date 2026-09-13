import RemoteConfigFeature
import Foundation
import Testing
import TestSupport
@testable import RemoteConfigAPI

@Suite struct RemoteConfigMapperTests {
    @Test(arguments: [199, 201, 300, 400, 500])
    func map_throwsOnNonOKResponse(statusCode: Int) throws {
        #expect(throws: RemoteConfigMapper.Error.invalidData) {
            try RemoteConfigMapper.map(
                makeRemoteConfigJSON(),
                from: anyHTTPURLResponse(statusCode: statusCode)
            )
        }
    }

    @Test func map_throwsOnOKWithInvalidJSON() {
        #expect(throws: RemoteConfigMapper.Error.invalidData) {
            try RemoteConfigMapper.map(invalidJSON(), from: anyHTTPURLResponse())
        }
    }

    @Test func map_deliversNothingOnAnEmptyDocument() throws {
        let configuration = try RemoteConfigMapper.map(
            makeRemoteConfigJSON(),
            from: anyHTTPURLResponse()
        )

        #expect(configuration == RemoteConfig())
    }

    @Test func map_deliversTheListingsPolicies() throws {
        let pageSize = 4
        let cacheMaxAgeInDays = 3

        let configuration = try RemoteConfigMapper.map(
            makeRemoteConfigJSON(listings: [
                "pageSize": pageSize, "cacheMaxAgeInDays": cacheMaxAgeInDays,
            ]),
            from: anyHTTPURLResponse()
        )

        #expect(
            configuration
                == RemoteConfig(
                    listingsPageSize: pageSize,
                    listingsCacheMaxAgeInDays: cacheMaxAgeInDays
                )
        )
    }

    @Test func map_deliversTheListingsHost() throws {
        let host = anyURL()

        let configuration = try RemoteConfigMapper.map(
            makeRemoteConfigJSON(listings: ["host": host.absoluteString]),
            from: anyHTTPURLResponse()
        )

        #expect(configuration == RemoteConfig(listingsHost: host))
    }

    @Test func map_deliversNoHost_whenTheDocumentHasNoValidURL() throws {
        let notAURL = ""

        let configuration = try RemoteConfigMapper.map(
            makeRemoteConfigJSON(listings: ["host": notAURL]),
            from: anyHTTPURLResponse()
        )

        #expect(configuration == RemoteConfig())
    }

    @Test func map_deliversTheSettingsLanguages() throws {
        let defaultLanguage = "vi"
        let supportedLanguages = ["en", "vi"]

        let configuration = try RemoteConfigMapper.map(
            makeRemoteConfigJSON(settings: [
                "defaultLanguage": defaultLanguage, "supportedLanguages": supportedLanguages,
            ]),
            from: anyHTTPURLResponse()
        )

        #expect(
            configuration
                == RemoteConfig(
                    defaultLanguage: defaultLanguage,
                    supportedLanguages: supportedLanguages
                )
        )
    }

    @Test func map_deliversTheTabs() throws {
        let tabs = ["listings", "settings"]

        let configuration = try RemoteConfigMapper.map(
            makeRemoteConfigJSON(tabs: tabs),
            from: anyHTTPURLResponse()
        )

        #expect(configuration == RemoteConfig(tabs: tabs))
    }
}
