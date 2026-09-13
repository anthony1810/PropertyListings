import Foundation
import RemoteConfigCache
import RemoteConfigFeature

struct BrandSource: Equatable, Sendable {
    static let cachePolicy = RemoteConfigCachePolicy(maxAgeInDays: 7)

    let documentURL: URL?
    let fallback: BrandConfiguration

    func brand(
        store: RemoteBrandStore,
        currentDate: @escaping @Sendable () -> Date = Date.init
    ) async -> BrandConfiguration {
        let loader = LocalRemoteBrandLoader(
            store: store,
            policy: Self.cachePolicy,
            currentDate: currentDate
        )
        guard let remote = try? await loader.load() else { return fallback }
        return BrandConfiguration(remote: remote, fallback: fallback) ?? fallback
    }
}
