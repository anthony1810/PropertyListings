import Foundation

public actor CodableBookmarkStore: BookmarkStore {
    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retrieve() async throws -> [LocalBookmark] {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return [] }
        let data = try Data(contentsOf: storeURL)
        return try JSONDecoder().decode([CodableBookmark].self, from: data).map(Self.local(from:))
    }

    public func insert(_ bookmark: LocalBookmark) async throws {
        var bookmarks = try await retrieve().filter { $0.id != bookmark.id }
        bookmarks.append(bookmark)
        try write(bookmarks)
    }

    public func delete(id: String) async throws {
        try write(try await retrieve().filter { $0.id != id })
    }

    private func write(_ bookmarks: [LocalBookmark]) throws {
        try JSONEncoder().encode(bookmarks.map(Self.codable(from:))).write(to: storeURL, options: .atomic)
    }
}

// MARK: - Codable to local

private extension CodableBookmarkStore {
    static func local(from codable: CodableBookmark) -> LocalBookmark {
        LocalBookmark(
            id: codable.id,
            title: codable.title,
            priceAmount: codable.priceAmount,
            priceCurrency: codable.priceCurrency,
            street: codable.street,
            postalCode: codable.postalCode,
            locality: codable.locality,
            imageURL: codable.imageURL,
            savedAt: codable.savedAt
        )
    }
}

// MARK: - Local to Codable

private extension CodableBookmarkStore {
    static func codable(from local: LocalBookmark) -> CodableBookmark {
        CodableBookmark(
            id: local.id,
            title: local.title,
            priceAmount: local.priceAmount,
            priceCurrency: local.priceCurrency,
            street: local.street,
            postalCode: local.postalCode,
            locality: local.locality,
            imageURL: local.imageURL,
            savedAt: local.savedAt
        )
    }
}

// MARK: - Codable representation

private extension CodableBookmarkStore {
    struct CodableBookmark: Codable {
        let id: String
        let title: String
        let priceAmount: Decimal?
        let priceCurrency: String?
        let street: String?
        let postalCode: String?
        let locality: String
        let imageURL: URL?
        let savedAt: Date
    }
}
