import DesignSystem
import Foundation

struct BrandConfiguration: Equatable, Sendable {
    struct Listings: Equatable, Sendable {
        let host: URL
        let pageSize: Int
        let cacheMaxAgeInDays: Int
    }

    struct Design: Equatable, Sendable {
        let radii: DSRadii
        let typeface: DSTypeface?
    }

    struct Tab: Equatable, Sendable, Identifiable {
        enum Icon: Equatable, Sendable {
            case symbol(String)
            case image(String)
        }

        let destination: AppRouter.Tab
        let icon: Icon

        var id: AppRouter.Tab { destination }
    }

    let listings: Listings
    let design: Design
    let tabs: [Tab]
}
