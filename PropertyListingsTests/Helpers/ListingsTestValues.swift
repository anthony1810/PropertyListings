import Foundation
import ListingsFeature
import ListingsTestSupport

func makeRemoteListing(
    id: String = "1",
    title: String = "A title",
    price: Decimal? = 100,
    street: String? = "A street"
) -> (model: Listing, json: [String: Any]) {
    let currency = "CHF"
    let imageURL = "https://a-url.com/\(id).jpg"
    let model = makeListing(
        id: id,
        title: title,
        price: price.map { Price(amount: $0, currency: currency) },
        street: street,
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
    return (model, json)
}

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let envelope: [String: Any] = ["from": 0, "size": 100, "total": items.count, "results": items, "maxFrom": 0]
    return try! JSONSerialization.data(withJSONObject: envelope)
}
