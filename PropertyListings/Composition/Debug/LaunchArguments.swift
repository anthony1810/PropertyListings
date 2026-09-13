#if DEBUG
import DesignSystem
import Foundation
import HTTPClient
import RemoteConfigCache

enum LaunchArguments {
    static let reset = "-reset"
    static let connectivity = "-connectivity"
    static let offline = "offline"
}

extension AppComposition {
    static func launch(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) async -> AppComposition {
        DSAppearance.apply(CurrentBrand.configuration.theme)
        if arguments.contains(LaunchArguments.reset) {
            try? FileManager.default.removeItem(at: storageDirectory)
        }
        let brand = await resolvedBrand(
            CurrentBrand.configuration,
            store: CodableRemoteBrandStore(storeURL: storeURL(named: "remote-brand.json"))
        )
        if let index = arguments.firstIndex(of: LaunchArguments.connectivity),
            arguments.indices.contains(index + 1),
            arguments[index + 1] == LaunchArguments.offline
        {
            return AppComposition(brand: brand, httpClient: AlwaysFailingHTTPClient())
        }
        return AppComposition(brand: brand, remoteConfigURL: CurrentBrand.remoteConfigURL)
    }
}

private struct AlwaysFailingHTTPClient: HTTPClient {
    struct Offline: Error {}

    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        throw Offline()
    }
}
#else
extension AppComposition {
    static func launch() async -> AppComposition {
        DSAppearance.apply(CurrentBrand.configuration.theme)
        let brand = await resolvedBrand(
            CurrentBrand.configuration,
            store: CodableRemoteBrandStore(storeURL: storeURL(named: "remote-brand.json"))
        )
        return AppComposition(brand: brand, remoteConfigURL: CurrentBrand.remoteConfigURL)
    }
}
#endif
