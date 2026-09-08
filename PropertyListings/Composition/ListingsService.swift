import Foundation
import HTTPClient
import ListingsAPI
import ListingsCache
import ListingsFeature

struct ListingsService: Sendable {
    private let httpClient: HTTPClient
    private let baseURL: URL
    private let localListings: LocalListingsLoader

    init(
        httpClient: HTTPClient,
        store: ListingsStore,
        baseURL: URL,
        currentDate: @escaping @Sendable () -> Date
    ) {
        self.httpClient = httpClient
        self.baseURL = baseURL
        self.localListings = LocalListingsLoader(store: store, currentDate: currentDate)
    }

    func validateCache() async {
        await localListings.validateCache()
    }

    func loadListings() async throws -> [Listing] {
        do {
            return try await loadAndCacheRemoteListings()
        } catch {
            try Task.checkCancellation()
            return try await localListings.load()
        }
    }
}

// MARK: - Cache decorator

private extension ListingsService {
    func loadAndCacheRemoteListings() async throws -> [Listing] {
        let listings = try await loadRemoteListings()
        try? await localListings.save(listings)
        return listings
    }
}

// MARK: - Remote

private extension ListingsService {
    func loadRemoteListings() async throws -> [Listing] {
        let url = ListingsEndpoint.get.url(baseURL: baseURL)
        let (data, response) = try await httpClient.get(from: url)
        return try ListingsMapper.map(data, from: response)
    }
}
