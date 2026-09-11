import DesignSystem
import Foundation

enum CurrentBrand {
    static let configuration = BrandConfiguration(
        listings: BrandConfiguration.Listings(
            host: URL(string: "https://private-9f1bb1-homegate3.apiary-mock.com")!,
            pageSize: 5,
            cacheMaxAgeInDays: 7
        ),
        design: BrandConfiguration.Design(
            radii: DSRadii(m: 12, l: 20),
            typeface: nil
        )
    )
}
