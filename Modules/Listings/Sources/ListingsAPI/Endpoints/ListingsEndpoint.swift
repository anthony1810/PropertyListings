import Foundation

public enum ListingsEndpoint {
    case page(from: Int, size: Int)

    public func url(baseURL: URL) -> URL {
        switch self {
        case let .page(from, size):
            return baseURL
                .appending(path: "properties")
                .appending(queryItems: [
                    URLQueryItem(name: "from", value: String(from)),
                    URLQueryItem(name: "size", value: String(size)),
                ])
        }
    }
}
