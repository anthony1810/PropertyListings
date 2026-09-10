import Foundation
@testable import PropertyListings

func makeBrand(
    listingsHost: URL = URL(string: "https://brand.example")!
) -> BrandConfiguration {
    BrandConfiguration(listingsHost: listingsHost)
}
