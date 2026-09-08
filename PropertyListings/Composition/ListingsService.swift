import Foundation
import HTTPClient
import ListingsAPI
import ListingsCache
import ListingsFeature

struct ListingsService: Sendable {
    private let httpClient: HTTPClient
    private let baseURL: URL

    init(httpClient: HTTPClient, baseURL: URL) {
        self.httpClient = httpClient
        self.baseURL = baseURL
    }

    func loadListings() async throws -> [Listing] {
        try await loadRemoteListings()
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
