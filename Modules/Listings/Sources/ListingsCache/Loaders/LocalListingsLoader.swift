import Foundation
import ListingsFeature

public struct LocalListingsLoader: Sendable {
    public enum Error: Swift.Error, Equatable { case cacheMiss }

    private let store: ListingsStore
    private let currentDate: @Sendable () -> Date

    public init(store: ListingsStore, currentDate: @escaping @Sendable () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    public func load() async throws -> [Listing] {
        guard let cache = try await store.retrieve(),
              ListingsCachePolicy.validate(cache.timestamp, against: currentDate())
        else { throw Error.cacheMiss }
        return cache.listings.map(Self.listing(from:))
    }
}

extension LocalListingsLoader: ListingsCache {
    public func save(_ listings: [Listing]) async throws {
        try await store.deleteCachedListings()
        try await store.insert(listings.map(Self.local(from:)), timestamp: currentDate())
    }
}

extension LocalListingsLoader {
    private struct InvalidCache: Swift.Error {}

    public func validateCache() async {
        do {
            if let cache = try await store.retrieve(),
               !ListingsCachePolicy.validate(cache.timestamp, against: currentDate()) {
                throw InvalidCache()
            }
        } catch {
            try? await store.deleteCachedListings()
        }
    }
}

// MARK: - Local to domain

private extension LocalListingsLoader {
    static func listing(from local: LocalListing) -> Listing {
        Listing(
            id: local.id,
            title: local.title,
            price: price(from: local),
            address: Address(street: local.street, postalCode: local.postalCode, locality: local.locality),
            imageURL: local.imageURL
        )
    }

    static func price(from local: LocalListing) -> Price? {
        guard let amount = local.priceAmount, let currency = local.priceCurrency else { return nil }
        return Price(amount: amount, currency: currency)
    }
}

// MARK: - Domain to local

private extension LocalListingsLoader {
    static func local(from listing: Listing) -> LocalListing {
        LocalListing(
            id: listing.id,
            title: listing.title,
            priceAmount: listing.price?.amount,
            priceCurrency: listing.price?.currency,
            street: listing.address.street,
            postalCode: listing.address.postalCode,
            locality: listing.address.locality,
            imageURL: listing.imageURL
        )
    }
}
