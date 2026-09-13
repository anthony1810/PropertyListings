import RemoteConfigFeature
import Foundation

public enum RemoteConfigMapper {
    public enum Error: Swift.Error, Equatable {
        case invalidData
    }

    public static func map(
        _ data: Data,
        from response: HTTPURLResponse
    ) throws -> RemoteConfig {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        return RemoteConfig(
            listingsHost: root.listings?.host.flatMap(URL.init(string:)),
            listingsPageSize: root.listings?.pageSize,
            listingsCacheMaxAgeInDays: root.listings?.cacheMaxAgeInDays,
            defaultLanguage: root.settings?.defaultLanguage,
            supportedLanguages: root.settings?.supportedLanguages,
            tabs: root.tabs
        )
    }
}

// MARK: - Remote representation

private extension RemoteConfigMapper {
    struct Root: Decodable {
        let listings: RemoteListings?
        let settings: RemoteSettings?
        let tabs: [String]?
    }

    struct RemoteListings: Decodable {
        let host: String?
        let pageSize: Int?
        let cacheMaxAgeInDays: Int?
    }

    struct RemoteSettings: Decodable {
        let defaultLanguage: String?
        let supportedLanguages: [String]?
    }
}
