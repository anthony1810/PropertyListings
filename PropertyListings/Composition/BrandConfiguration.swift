import DesignSystem
import Foundation
import SettingsFeature

struct BrandConfiguration: Equatable, Sendable {
    let listings: Listings
    let design: Design
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

// MARK: - Design

extension BrandConfiguration {
    struct Design: Equatable, Sendable {
        let radii: DSRadii
        let typeface: DSTypeface?
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
