import Foundation

public enum ListingsEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appending(path: "properties")
        }
    }
}
