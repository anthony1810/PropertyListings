import DesignSystem
import Foundation
import RemoteConfigCache

extension AppComposition {
    static func launch() async -> AppComposition {
        DSAppearance.apply(CurrentBrand.source.fallback.theme)
        LaunchOverrides.resetStorage(at: storageDirectory)
        let brand = await resolvedBrand(
            CurrentBrand.source.fallback,
            store: CodableRemoteBrandStore(storeURL: storeURL(named: "remote-brand.json"))
        )
        guard let httpClient = LaunchOverrides.httpClient() else {
            return AppComposition(brand: brand, brandDocumentURL: CurrentBrand.source.documentURL)
        }
        return AppComposition(
            brand: brand,
            httpClient: httpClient,
            brandDocumentURL: CurrentBrand.source.documentURL
        )
    }
}
