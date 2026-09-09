import Foundation

public struct LocalListing: Equatable, Sendable {
    public let id: String
    public let title: String
    public let priceAmount: Decimal?
    public let priceCurrency: String?
    public let street: String?
    public let postalCode: String?
    public let locality: String
    public let imageURL: URL?

    public init(
        id: String,
        title: String,
        priceAmount: Decimal?,
        priceCurrency: String?,
        street: String?,
        postalCode: String?,
        locality: String,
        imageURL: URL?
    ) {
        self.id = id
        self.title = title
        self.priceAmount = priceAmount
        self.priceCurrency = priceCurrency
        self.street = street
        self.postalCode = postalCode
        self.locality = locality
        self.imageURL = imageURL
    }
}
