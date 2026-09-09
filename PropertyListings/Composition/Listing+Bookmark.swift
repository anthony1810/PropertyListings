import BookmarksFeature
import Foundation
import ListingsFeature

extension Bookmark {
    init(listing: Listing, savedAt: Date) {
        self.init(
            id: listing.id,
            title: listing.title,
            price: listing.price.map { Price(amount: $0.amount, currency: $0.currency) },
            address: Address(
                street: listing.address.street,
                postalCode: listing.address.postalCode,
                locality: listing.address.locality
            ),
            imageURL: listing.imageURL,
            savedAt: savedAt
        )
    }
}
