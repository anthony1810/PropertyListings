import ListingsFeature

public struct ListingsPage: Equatable, Sendable {
    public let listings: [Listing]
    public let from: Int
    public let size: Int
    public let total: Int
    public let maxFrom: Int

    public init(listings: [Listing], from: Int, size: Int, total: Int, maxFrom: Int) {
        self.listings = listings
        self.from = from
        self.size = size
        self.total = total
        self.maxFrom = maxFrom
    }

    public var nextFrom: Int? {
        let next = from + size
        guard next < total, next <= maxFrom else { return nil }
        return next
    }
}
