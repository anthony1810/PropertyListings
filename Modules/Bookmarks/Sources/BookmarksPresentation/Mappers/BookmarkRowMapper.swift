import BookmarksFeature
import Foundation
import SharedPresentation

public enum BookmarkRowMapper {
    public static func map(_ bookmark: Bookmark, locale: Locale) -> BookmarkRow {
        BookmarkRow(
            id: bookmark.id,
            title: bookmark.title,
            priceText: PriceFormatter.text(
                amount: bookmark.price?.amount,
                currency: bookmark.price?.currency,
                locale: locale
            ),
            addressText: AddressFormatter.text(
                street: bookmark.address.street,
                postalCode: bookmark.address.postalCode,
                locality: bookmark.address.locality
            ),
            imageURL: bookmark.imageURL
        )
    }
}
