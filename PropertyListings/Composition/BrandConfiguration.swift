import DesignSystem
import Foundation
import RemoteConfigFeature
import SettingsFeature

struct BrandConfiguration: Equatable, Sendable {
    let listings: Listings
    let theme: DSTheme
    let tabs: [Tab]
    let settings: Settings

}

// MARK: - Listings

extension BrandConfiguration {
    struct Listings: Equatable, Sendable {
        let host: URL
        let pageSize: Int
        let cacheMaxAgeInDays: Int
    }
}

// MARK: - Tabs

extension BrandConfiguration {
    struct Tab: Equatable, Sendable, Identifiable {
        enum Icon: Equatable, Sendable {
            case symbol(String)
            case image(String)
        }

        let destination: AppRouter.Tab
        let icon: Icon

        var id: AppRouter.Tab { destination }
    }
}

// MARK: - Settings

extension BrandConfiguration {
    struct Settings: Equatable, Sendable {
        let defaultLanguage: AppLanguage
        let supportedLanguages: [AppLanguage]

        func initialLanguage(preferring languageCodes: [String]) -> AppLanguage {
            languageCodes.lazy
                .compactMap(AppLanguage.init(rawValue:))
                .first { supportedLanguages.contains($0) } ?? defaultLanguage
        }
    }
}

// MARK: - Building from a remote document

extension BrandConfiguration {
    init?(remote: RemoteBrand, fallback: BrandConfiguration) {
        guard remote.listingsHost.scheme == "https",
            let supported = Self.languages(remote.supportedLanguages),
            let defaultLanguage = AppLanguage(rawValue: remote.defaultLanguage),
            supported.contains(defaultLanguage),
            let tabs = Self.tabs(remote.tabs, from: fallback.tabs)
        else { return nil }
        self.init(
            listings: Listings(
                host: remote.listingsHost,
                pageSize: remote.listingsPageSize,
                cacheMaxAgeInDays: remote.listingsCacheMaxAgeInDays
            ),
            theme: fallback.theme,
            tabs: tabs,
            settings: Settings(defaultLanguage: defaultLanguage, supportedLanguages: supported)
        )
    }

    private static func languages(_ names: [String]) -> [AppLanguage]? {
        let known = names.compactMap(AppLanguage.init(rawValue:))
        return known.count == names.count && !known.isEmpty ? known : nil
    }

    private static func tabs(_ names: [String], from available: [Tab]) -> [Tab]? {
        let destinations = names.compactMap(AppRouter.Tab.init(rawValue:))
        guard destinations.count == names.count else { return nil }
        let tabs = destinations.compactMap { destination in
            available.first { $0.destination == destination }
        }
        guard tabs.count == names.count, tabs.contains(where: { $0.destination == .listings })
        else { return nil }
        return tabs
    }
}
