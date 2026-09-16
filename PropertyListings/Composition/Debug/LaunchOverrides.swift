import Foundation
import HTTPClient

#if DEBUG
enum LaunchArguments {
    static let reset = "-reset"
    static let connectivity = "-connectivity"
    static let offline = "offline"
}

enum LaunchOverrides {
    static func resetStorage(
        at directory: URL,
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) {
        guard arguments.contains(LaunchArguments.reset) else { return }
        try? FileManager.default.removeItem(at: directory)
    }

    static func httpClient(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> HTTPClient? {
        guard let index = arguments.firstIndex(of: LaunchArguments.connectivity),
            arguments.indices.contains(index + 1),
            arguments[index + 1] == LaunchArguments.offline
        else { return nil }
        return AlwaysFailingHTTPClient()
    }
}

private struct AlwaysFailingHTTPClient: HTTPClient {
    struct Offline: Error {}

    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        throw Offline()
    }
}
#else
enum LaunchOverrides {
    static func resetStorage(at directory: URL) {}

    static func httpClient() -> HTTPClient? { nil }
}
#endif
