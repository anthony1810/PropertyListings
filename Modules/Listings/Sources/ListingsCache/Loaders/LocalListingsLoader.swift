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
