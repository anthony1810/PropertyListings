import Foundation
import ListingsFeature
import SharedPresentation

public enum ListingRowMapper {
    public static func map(_ listing: Listing, isBookmarked: Bool, locale: Locale) -> ListingRow {
        ListingRow(
            id: listing.id,
            title: listing.title,
            priceText: PriceFormatter.text(
                amount: listing.price?.amount,
                currency: listing.price?.currency,
                locale: locale
            ),
            addressText: AddressFormatter.text(
                street: listing.address.street,
                postalCode: listing.address.postalCode,
                locality: listing.address.locality
            ),
            imageURL: listing.imageURL,
            isBookmarked: isBookmarked
        )
    }
}
