import Foundation

enum CurrentBrand {
    static let configuration = BrandConfiguration(
        listings: BrandConfiguration.Listings(
            host: URL(string: "https://private-9f1bb1-homegate3.apiary-mock.com")!,
            pageSize: 5,
            cacheMaxAgeInDays: 7
        )
    )
}
