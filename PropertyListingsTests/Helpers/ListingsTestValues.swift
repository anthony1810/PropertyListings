import Foundation
import ListingsCache
import ListingsFeature
import ListingsTestSupport

func makeRemoteListing(
    id: String = "1",
    title: String = "A title",
    price: Decimal? = 100,
    street: String? = "A street",
    postalCode: String? = "8000",
    locality: String = "A locality"
) -> (model: Listing, local: LocalListing, json: [String: Any]) {
    let currency = "CHF"
    let imageURL = "https://a-url.com/\(id).jpg"
    let model = makeListing(
        id: id,
        title: title,
        price: price.map { Price(amount: $0, currency: currency) },
        street: street,
        postalCode: postalCode,
        locality: locality,
        imageURL: URL(string: imageURL)
    )
    var prices: [String: Any] = ["currency": currency]
    if let price { prices["buy"] = ["price": NSDecimalNumber(decimal: price)] }
    let address: [String: String?] = [
        "street": street,
        "postalCode": model.address.postalCode,
        "locality": model.address.locality,
    ]
    let json: [String: Any] = [
        "id": id,
        "listing": [
            "prices": prices,
            "address": address.compactMapValues { $0 },
            "localization": [
                "primary": "de",
                "de": ["attachments": [["type": "IMAGE", "url": imageURL]], "text": ["title": title]],
            ],
        ],
    ]
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
    return (model, local, json)
}

func makeItemsJSON(
    _ items: [[String: Any]],
    from: Int = 0,
    size: Int = 100,
    total: Int? = nil,
    maxFrom: Int = 0
) -> Data {
    let envelope: [String: Any] = [
        "from": from,
        "size": size,
        "total": total ?? items.count,
        "results": items,
        "maxFrom": maxFrom,
    ]
    return try! JSONSerialization.data(withJSONObject: envelope)
}
