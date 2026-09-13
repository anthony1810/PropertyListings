import DesignSystem
import Foundation
import RemoteConfigFeature
import SettingsFeature

struct BrandConfiguration: Equatable, Sendable {
    let listings: Listings
    let theme: DSTheme
    let tabs: [Tab]
    let settings: Settings

    func applying(_ remote: RemoteConfig) -> BrandConfiguration {
        BrandConfiguration(
            listings: appliedListings(remote),
            theme: theme,
            tabs: appliedTabs(remote),
            settings: appliedSettings(remote)
        )
    }
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

// MARK: - Applying a remote document

extension BrandConfiguration {
    private func appliedListings(_ remote: RemoteConfig) -> Listings {
        Listings(
            host: remote.listingsHost.flatMap(Self.secure) ?? listings.host,
            pageSize: Self.pageSizes.accepting(remote.listingsPageSize) ?? listings.pageSize,
            cacheMaxAgeInDays: Self.cacheAgesInDays.accepting(remote.listingsCacheMaxAgeInDays)
                ?? listings.cacheMaxAgeInDays
        )
    }

    private func appliedSettings(_ remote: RemoteConfig) -> Settings {
        let supported =
            Self.knownLanguages(remote.supportedLanguages) ?? settings.supportedLanguages
        let requested = remote.defaultLanguage.flatMap(AppLanguage.init(rawValue:))
        let candidates = [requested, settings.defaultLanguage].compactMap { $0 }
        return Settings(
            defaultLanguage: candidates.first(where: supported.contains) ?? supported[0],
            supportedLanguages: supported
        )
    }

    private func appliedTabs(_ remote: RemoteConfig) -> [Tab] {
        guard let names = remote.tabs else { return tabs }
        let applied =
            names
            .compactMap(AppRouter.Tab.init(rawValue:))
            .compactMap { destination in tabs.first { $0.destination == destination } }
        guard applied.contains(where: { $0.destination == .listings }) else { return tabs }
        return applied
    }

    private static let pageSizes = 1...50
    private static let cacheAgesInDays = 1...30

    private static func secure(_ url: URL) -> URL? {
        url.scheme == "https" ? url : nil
    }

    private static func knownLanguages(_ names: [String]?) -> [AppLanguage]? {
        guard let names else { return nil }
        let known = names.compactMap(AppLanguage.init(rawValue:))
        return known.isEmpty ? nil : known
    }
}

private extension ClosedRange where Bound == Int {
    func accepting(_ value: Int?) -> Int? {
        guard let value, contains(value) else { return nil }
        return value
    }
}
