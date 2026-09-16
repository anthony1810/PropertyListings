import Foundation
import RemoteConfigCache
import RemoteConfigFeature
import TestSupport

func makeRemoteBrandPair(pageSize: Int = 4) -> (model: RemoteBrand, local: LocalRemoteBrand) {
    let model = RemoteBrand(
        listingsHost: anyURL(),
        listingsPageSize: pageSize,
        listingsCacheMaxAgeInDays: 3,
        defaultLanguage: "en",
        supportedLanguages: ["en", "vi"],
        tabs: ["listings", "settings"]
    )
    let local = LocalRemoteBrand(
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
