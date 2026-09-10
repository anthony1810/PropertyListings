import Foundation

struct BrandConfiguration: Equatable, Sendable {
    struct Listings: Equatable, Sendable {
        let host: URL
        let pageSize: Int
        let cacheMaxAgeInDays: Int
    }

    let listings: Listings
}
