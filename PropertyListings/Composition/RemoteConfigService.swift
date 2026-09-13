import Foundation
import HTTPClient
import RemoteConfigAPI
import RemoteConfigCache
import RemoteConfigFeature

struct RemoteConfigService: Sendable {
    private let httpClient: HTTPClient
    private let baseURL: URL
    private let localConfiguration: LocalRemoteConfigLoader

    init(
        httpClient: HTTPClient,
        store: RemoteConfigStore,
        baseURL: URL,
        cachePolicy: RemoteConfigCachePolicy,
        currentDate: @escaping @Sendable () -> Date
    ) {
        self.httpClient = httpClient
        self.baseURL = baseURL
        self.localConfiguration = LocalRemoteConfigLoader(
            store: store,
            policy: cachePolicy,
            currentDate: currentDate
        )
    }

    func cachedConfiguration() async -> RemoteConfig {
        (try? await localConfiguration.load()) ?? RemoteConfig()
    }

    func refresh() async {
        guard let configuration = try? await loadRemoteConfiguration() else { return }
        try? await localConfiguration.save(configuration)
    }
}

// MARK: - Remote

private extension RemoteConfigService {
    func loadRemoteConfiguration() async throws -> RemoteConfig {
        let url = RemoteConfigEndpoint.current.url(baseURL: baseURL)
        let (data, response) = try await httpClient.get(from: url)
        return try RemoteConfigMapper.map(data, from: response)
    }
}
