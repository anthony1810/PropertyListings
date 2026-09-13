import Foundation
import RemoteConfigCache
import RemoteConfigFeature

func makeRemoteConfigPair(
    pageSize: Int? = 4,
    tabs: [String]? = ["listings", "settings"]
) -> (model: RemoteConfig, local: LocalRemoteConfig) {
    let model = RemoteConfig(listingsPageSize: pageSize, tabs: tabs)
    let local = LocalRemoteConfig(
        listingsHost: model.listingsHost,
        listingsPageSize: model.listingsPageSize,
        listingsCacheMaxAgeInDays: model.listingsCacheMaxAgeInDays,
        defaultLanguage: model.defaultLanguage,
        supportedLanguages: model.supportedLanguages,
        tabs: model.tabs
    )
    return (model, local)
}

extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
