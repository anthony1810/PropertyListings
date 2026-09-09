import Foundation

public struct Bookmark: Equatable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let price: Price?
    public let address: Address
    public let imageURL: URL?
    public let savedAt: Date

    public init(
        id: String,
        title: String,
        price: Price?,
        address: Address,
        imageURL: URL?,
        savedAt: Date
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.address = address
        self.imageURL = imageURL
        self.savedAt = savedAt
    }
}
