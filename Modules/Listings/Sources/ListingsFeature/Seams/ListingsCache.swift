public protocol ListingsCache: Sendable {
    func save(_ listings: [Listing]) async throws
}
