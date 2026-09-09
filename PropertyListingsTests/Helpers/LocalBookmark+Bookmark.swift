import BookmarksFeature
import BookmarksPersistence

extension LocalBookmark {
    init(bookmark: Bookmark) {
        self.init(
            id: bookmark.id,
            title: bookmark.title,
            priceAmount: bookmark.price?.amount,
            priceCurrency: bookmark.price?.currency,
            street: bookmark.address.street,
            postalCode: bookmark.address.postalCode,
            locality: bookmark.address.locality,
            imageURL: bookmark.imageURL,
            savedAt: bookmark.savedAt
        )
    }
}
