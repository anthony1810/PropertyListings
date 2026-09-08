import Foundation
import ListingsFeature

public func makeListing(
    id: String = "any",
    title: String = "A title",
    price: Price? = Price(amount: 1_000, currency: "CHF"),
    street: String? = "A street",
    postalCode: String? = "8000",
    locality: String = "A locality",
    imageURL: URL? = URL(string: "https://a-url.com/any.jpg")
) -> Listing {
    Listing(
        id: id,
        title: title,
        price: price,
        address: Address(street: street, postalCode: postalCode, locality: locality),
        imageURL: imageURL
    )
}
