#if DEBUG
import Foundation
import HTTPClient

enum LaunchArguments {
    static let reset = "-reset"
    static let connectivity = "-connectivity"
    static let offline = "offline"
}

extension AppComposition {
    static func launch(arguments: [String] = ProcessInfo.processInfo.arguments) -> AppComposition {
        if arguments.contains(LaunchArguments.reset) {
            try? FileManager.default.removeItem(at: storageDirectory)
        }
        if let index = arguments.firstIndex(of: LaunchArguments.connectivity),
           arguments.indices.contains(index + 1),
           arguments[index + 1] == LaunchArguments.offline {
            return AppComposition(brand: CurrentBrand.configuration, httpClient: AlwaysFailingHTTPClient())
        }
        return AppComposition(brand: CurrentBrand.configuration)
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
    static func launch() -> AppComposition {
        AppComposition(brand: CurrentBrand.configuration)
    }
}
#endif
