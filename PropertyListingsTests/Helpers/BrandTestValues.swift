import DesignSystem
import Foundation
@testable import PropertyListings

func makeBrand(
    listingsHost: URL = URL(string: "https://brand.example")!,
    listingsPageSize: Int = 5,
    listingsCacheMaxAgeInDays: Int = 7,
    radii: DSRadii = .designSystem
) -> BrandConfiguration {
    BrandConfiguration(
        listings: BrandConfiguration.Listings(
            host: listingsHost,
            pageSize: listingsPageSize,
            cacheMaxAgeInDays: listingsCacheMaxAgeInDays
        ),
        design: BrandConfiguration.Design(radii: radii)
    )
}
