import DesignSystem
import Foundation

enum CurrentBrand {
    static let configuration = BrandConfiguration(
        listings: BrandConfiguration.Listings(
            host: URL(string: "https://raw.githubusercontent.com/anthony1810/PropertyListings/main/docs/mock/lakeside")!,
            pageSize: 4,
            cacheMaxAgeInDays: 3
        ),
        design: BrandConfiguration.Design(
            radii: DSRadii(m: 16, l: 28)
        )
    )
}
