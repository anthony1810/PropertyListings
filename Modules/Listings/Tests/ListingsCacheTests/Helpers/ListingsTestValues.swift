import Foundation
import ListingsCache
import ListingsFeature

func makeListing(
    id: String = "any",
    price: Price? = Price(amount: 1_000, currency: "CHF")
) -> (model: Listing, local: LocalListing) {
    let imageURL = URL(string: "https://a-url.com/\(id).jpg")
    let model = Listing(
        id: id,
        title: "A title",
        price: price,
        address: Address(street: "A street", postalCode: "8000", locality: "A locality"),
        imageURL: imageURL
    )
    let local = LocalListing(
        id: id,
        title: "A title",
        priceAmount: price?.amount,
        priceCurrency: price?.currency,
        street: "A street",
        postalCode: "8000",
        locality: "A locality",
        imageURL: imageURL
    )
    return (model, local)
}

func makeLocalListing(id: String = "any") -> LocalListing {
    makeListing(id: id).local
}
