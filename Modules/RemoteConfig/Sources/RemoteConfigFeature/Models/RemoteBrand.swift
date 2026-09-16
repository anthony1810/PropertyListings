import Foundation

public struct RemoteBrand: Equatable, Sendable {
    public let listingsHost: URL
    public let listingsPageSize: Int
    public let listingsCacheMaxAgeInDays: Int
    public let defaultLanguage: String
    public let supportedLanguages: [String]
    public let tabs: [String]

    public init(
        listingsHost: URL,
        listingsPageSize: Int,
        listingsCacheMaxAgeInDays: Int,
        defaultLanguage: String,
        supportedLanguages: [String],
        tabs: [String]
    ) {
        self.listingsHost = listingsHost
        self.listingsPageSize = listingsPageSize
        self.listingsCacheMaxAgeInDays = listingsCacheMaxAgeInDays
        self.defaultLanguage = defaultLanguage
        self.supportedLanguages = supportedLanguages
        self.tabs = tabs
    }
}
