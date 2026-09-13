import Foundation

public struct RemoteConfig: Equatable, Sendable {
    public let listingsHost: URL?
    public let listingsPageSize: Int?
    public let listingsCacheMaxAgeInDays: Int?
    public let defaultLanguage: String?
    public let supportedLanguages: [String]?
    public let tabs: [String]?

    public init(
        listingsHost: URL? = nil,
        listingsPageSize: Int? = nil,
        listingsCacheMaxAgeInDays: Int? = nil,
        defaultLanguage: String? = nil,
        supportedLanguages: [String]? = nil,
        tabs: [String]? = nil
    ) {
        self.listingsHost = listingsHost
        self.listingsPageSize = listingsPageSize
        self.listingsCacheMaxAgeInDays = listingsCacheMaxAgeInDays
        self.defaultLanguage = defaultLanguage
        self.supportedLanguages = supportedLanguages
        self.tabs = tabs
    }
}
