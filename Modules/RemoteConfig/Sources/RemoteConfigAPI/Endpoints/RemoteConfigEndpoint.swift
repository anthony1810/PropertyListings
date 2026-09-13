import Foundation

public enum RemoteConfigEndpoint {
    case current

    public func url(baseURL: URL) -> URL {
        switch self {
        case .current:
            return baseURL.appending(path: "configuration")
        }
    }
}
