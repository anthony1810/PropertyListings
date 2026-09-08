import Foundation
import HTTPClient
import ListingsAPI
import ListingsCache
import ListingsFeature

struct ListingsService: Sendable {
    static let pageSize = 5

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

    func loadListings() async throws -> Paginated<Listing> {
        do {
            return try await loadAndCacheRemoteListings()
        } catch {
            try Task.checkCancellation()
            return Paginated(items: try await localListings.load())
        }
    }
}

// MARK: - Cache decorator

private extension ListingsService {
    func loadAndCacheRemoteListings() async throws -> Paginated<Listing> {
        try await loadAndCacheRemotePage(from: 0, appendingTo: [])
    }

    func loadAndCacheRemotePage(from: Int, appendingTo loaded: [Listing]) async throws -> Paginated<Listing> {
        let page = try await loadRemotePage(from: from)
        let listings = loaded + page.listings
        try? await localListings.save(listings)
        guard let nextFrom = page.nextFrom else { return Paginated(items: listings) }
        return Paginated(items: listings) {
            try await loadAndCacheRemotePage(from: nextFrom, appendingTo: listings)
        }
    }
}

// MARK: - Remote

private extension ListingsService {
    func loadRemotePage(from: Int) async throws -> ListingsPage {
        let url = ListingsEndpoint.page(from: from, size: Self.pageSize).url(baseURL: baseURL)
        let (data, response) = try await httpClient.get(from: url)
        return try ListingsMapper.map(data, from: response)
    }
}
