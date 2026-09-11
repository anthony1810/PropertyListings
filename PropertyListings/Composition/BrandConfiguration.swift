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

    let listings: Listings
    let design: Design
}
