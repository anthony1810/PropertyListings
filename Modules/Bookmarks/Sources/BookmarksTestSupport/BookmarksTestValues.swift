import BookmarksFeature
import Foundation

public func makeBookmark(
    id: String = "any",
    title: String = "A title",
    price: Price? = Price(amount: 1_000, currency: "CHF"),
    street: String? = "A street",
    postalCode: String? = "8000",
    locality: String = "A locality",
    imageURL: URL? = URL(string: "https://a-url.com/any.jpg"),
    savedAt: Date = Date()
) -> Bookmark {
    Bookmark(
        id: id,
        title: title,
        price: price,
        address: Address(street: street, postalCode: postalCode, locality: locality),
        imageURL: imageURL,
        savedAt: savedAt
    )
}
