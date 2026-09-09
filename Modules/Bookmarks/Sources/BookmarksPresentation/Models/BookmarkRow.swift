import Foundation

public struct BookmarkRow: Equatable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let priceText: String
    public let addressText: String
    public let imageURL: URL?

    public init(id: String, title: String, priceText: String, addressText: String, imageURL: URL?) {
        self.id = id
        self.title = title
        self.priceText = priceText
        self.addressText = addressText
        self.imageURL = imageURL
    }
}
