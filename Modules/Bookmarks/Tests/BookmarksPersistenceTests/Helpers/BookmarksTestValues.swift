import BookmarksFeature
import BookmarksPersistence
import BookmarksTestSupport
import Foundation

func makeBookmarkPair(
    id: String = "any",
    price: Price? = Price(amount: 1_000, currency: "CHF"),
    savedAt: Date = Date()
) -> (model: Bookmark, local: LocalBookmark) {
    let model = makeBookmark(id: id, price: price, savedAt: savedAt)
    let local = LocalBookmark(
        id: model.id,
        title: model.title,
        priceAmount: model.price?.amount,
        priceCurrency: model.price?.currency,
        street: model.address.street,
        postalCode: model.address.postalCode,
        locality: model.address.locality,
        imageURL: model.imageURL,
        savedAt: model.savedAt
    )
    return (model, local)
}

func makeLocalBookmark(id: String = "any", savedAt: Date = Date()) -> LocalBookmark {
    makeBookmarkPair(id: id, savedAt: savedAt).local
}
