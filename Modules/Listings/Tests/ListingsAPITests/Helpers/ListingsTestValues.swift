import Foundation
import ListingsFeature
import TestSupport

func makeListing(
    id: String = "1",
    title: String = "A title",
    price: Decimal? = 100,
    priceKind: String = "buy",
    currency: String? = "CHF",
    street: String? = "Street 1",
    postalCode: String? = "8000",
    locality: String = "Zürich",
    primaryLanguage: String = "de",
    attachments: [(type: String, url: String)] = [("IMAGE", "https://img.example/1.jpg")],
    languageBlocks: [String: [String: Any]]? = nil
) -> (model: Listing, json: [String: Any]) {
    let imageURL = attachments.first { $0.type == "IMAGE" }.flatMap { URL(string: $0.url) }
    let expectedPrice: Price? = if let price, let currency {
        Price(amount: price, currency: currency)
    } else {
        nil
    }
    let model = Listing(
        id: id,
        title: title,
        price: expectedPrice,
        address: Address(street: street, postalCode: postalCode, locality: locality),
        imageURL: imageURL
    )
    let address: [String: String?] = ["street": street, "postalCode": postalCode, "locality": locality]
    var localization: [String: Any] = ["primary": primaryLanguage]
    let defaultBlock: [String: Any] = [
        "text": ["title": title],
        "attachments": attachments.map { ["type": $0.type, "url": $0.url] },
    ]
    for (language, block) in languageBlocks ?? [primaryLanguage: defaultBlock] {
        localization[language] = block
    }
    var prices: [String: Any] = [:]
    if let currency { prices["currency"] = currency }
    prices[priceKind] = price.map { ["price": NSDecimalNumber(decimal: $0)] } ?? [:]
    let json: [String: Any] = [
        "id": id,
        "listing": [
            "prices": prices,
            "address": address.compactMapValues { $0 },
            "localization": localization,
        ],
    ]
    return (model, json)
}

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let envelope: [String: Any] = ["from": 0, "size": 100, "total": items.count, "results": items, "maxFrom": 0]
    return try! JSONSerialization.data(withJSONObject: envelope)
}
