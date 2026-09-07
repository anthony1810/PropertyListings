import Foundation

public struct Listing: Sendable, Hashable, Identifiable {
    public let id: String
    public let title: String
    public let price: Price?
    public let address: Address
    public let imageURL: URL?

    public init(
        id: String,
        title: String,
        price: Price?,
        address: Address,
        imageURL: URL?
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.address = address
        self.imageURL = imageURL
    }
}
