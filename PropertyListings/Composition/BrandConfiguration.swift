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
    }

    let listings: Listings
    let design: Design
}
