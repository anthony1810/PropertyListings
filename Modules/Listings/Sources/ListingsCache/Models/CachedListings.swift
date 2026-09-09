import Foundation

public struct CachedListings: Equatable, Sendable {
    public let listings: [LocalListing]
    public let timestamp: Date

    public init(listings: [LocalListing], timestamp: Date) {
        self.listings = listings
        self.timestamp = timestamp
    }
}
