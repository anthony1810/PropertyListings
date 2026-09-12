import DesignSystem
import Foundation

enum CurrentBrand {
    static let configuration = BrandConfiguration(
        listings: BrandConfiguration.Listings(
            host: URL(string: "https://raw.githubusercontent.com")!
                .appending(path: "anthony1810/PropertyListings/main/docs/mock/lakeside"),
            pageSize: 4,
            cacheMaxAgeInDays: 3
        ),
        design: BrandConfiguration.Design(
            radii: DSRadii(m: 16, l: 28),
            typeface: DSTypeface(
                regular: "Fraunces-Regular",
                semibold: "Fraunces-SemiBold",
                bold: "Fraunces-Bold"
            )
        ),
        tabs: [
            BrandConfiguration.Tab(destination: .listings, icon: .image("TabListings")),
            BrandConfiguration.Tab(destination: .settings, icon: .image("TabSettings")),
        ]
    )
}
