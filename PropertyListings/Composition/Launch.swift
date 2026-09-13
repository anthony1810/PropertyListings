import DesignSystem
import Foundation
import HTTPClient
import HTTPClientLive
import RemoteConfigCache

extension AppComposition {
    static func launch() async -> AppComposition {
        let source = CurrentBrand.source
        DSAppearance.apply(source.fallback.theme)
        LaunchOverrides.resetStorage(at: storageDirectory)

        let httpClient = LaunchOverrides.httpClient() ?? liveHTTPClient()
        let store = CodableRemoteBrandStore(storeURL: storeURL(named: "remote-brand.json"))
        let brand = await source.brand(store: store)

        return AppComposition(
            brand: brand,
            httpClient: httpClient,
            refreshBrand: refresher(for: source, httpClient: httpClient, store: store)
        )
    }

    private static func liveHTTPClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }

    private static func refresher(
        for source: BrandSource,
        httpClient: HTTPClient,
        store: RemoteBrandStore
    ) -> @Sendable () async -> Void {
        guard let documentURL = source.documentURL else { return {} }
        let service = RemoteConfigService(
            httpClient: httpClient,
            store: store,
            baseURL: documentURL,
            cachePolicy: BrandSource.cachePolicy,
            currentDate: Date.init
        )
        return { await service.refresh() }
    }
}
