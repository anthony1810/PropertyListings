import Foundation
import HTTPClient
import RemoteConfigAPI
import RemoteConfigCache
import RemoteConfigFeature

struct RemoteConfigService: Sendable {
    private let httpClient: HTTPClient
    private let baseURL: URL
    private let localBrand: LocalRemoteBrandLoader

    init(
        httpClient: HTTPClient,
        store: RemoteBrandStore,
        baseURL: URL,
        cachePolicy: RemoteConfigCachePolicy,
        currentDate: @escaping @Sendable () -> Date
    ) {
        self.httpClient = httpClient
        self.baseURL = baseURL
        self.localBrand = LocalRemoteBrandLoader(
            store: store,
            policy: cachePolicy,
            currentDate: currentDate
        )
    }

    func cachedBrand() async -> RemoteBrand? {
        try? await localBrand.load()
    }

    func refresh() async {
        guard let brand = try? await loadRemoteBrand() else { return }
        try? await localBrand.save(brand)
    }
}

// MARK: - Remote

private extension RemoteConfigService {
    func loadRemoteBrand() async throws -> RemoteBrand {
        let url = RemoteBrandEndpoint.current.url(baseURL: baseURL)
        let (data, response) = try await httpClient.get(from: url)
        return try RemoteBrandMapper.map(data, from: response)
    }
}
