import BookmarksFeature
import Foundation

public actor LocalBookmarksLoader {
    private let store: BookmarkStore

    public init(store: BookmarkStore) {
        self.store = store
    }

    public func load() async throws -> [Bookmark] {
        try await store.retrieve()
            .map(Self.bookmark(from:))
            .sorted { $0.savedAt > $1.savedAt }
    }

    public func save(_ bookmark: Bookmark) async throws {
        try await store.insert(Self.local(from: bookmark))
    }

    public func remove(id: Bookmark.ID) async throws {
        try await store.delete(id: id)
    }
}

// MARK: - Local to domain

private extension LocalBookmarksLoader {
    static func bookmark(from local: LocalBookmark) -> Bookmark {
        Bookmark(
            id: local.id,
            title: local.title,
            price: price(from: local),
            address: Address(street: local.street, postalCode: local.postalCode, locality: local.locality),
            imageURL: local.imageURL,
            savedAt: local.savedAt
        )
    }

    static func price(from local: LocalBookmark) -> Price? {
        guard let amount = local.priceAmount, let currency = local.priceCurrency else { return nil }
        return Price(amount: amount, currency: currency)
    }
}

// MARK: - Domain to local

private extension LocalBookmarksLoader {
    static func local(from bookmark: Bookmark) -> LocalBookmark {
        LocalBookmark(
            id: bookmark.id,
            title: bookmark.title,
            priceAmount: bookmark.price?.amount,
            priceCurrency: bookmark.price?.currency,
            street: bookmark.address.street,
            postalCode: bookmark.address.postalCode,
            locality: bookmark.address.locality,
            imageURL: bookmark.imageURL,
            savedAt: bookmark.savedAt
        )
    }
}
