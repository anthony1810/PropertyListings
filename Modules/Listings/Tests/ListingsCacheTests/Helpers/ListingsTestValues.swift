import Foundation
import ListingsCache
import ListingsFeature
import ListingsTestSupport

func makeListingPair(
    id: String = "any",
    price: Price? = Price(amount: 1_000, currency: "CHF")
) -> (model: Listing, local: LocalListing) {
    let model = makeListing(id: id, price: price)
    let local = LocalListing(
        id: model.id,
        title: model.title,
        priceAmount: model.price?.amount,
        priceCurrency: model.price?.currency,
        street: model.address.street,
        postalCode: model.address.postalCode,
        locality: model.address.locality,
        imageURL: model.imageURL
    )
    return (model, local)
}

func makeLocalListing(id: String = "any") -> LocalListing {
    makeListingPair(id: id).local
}
