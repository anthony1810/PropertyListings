import Foundation
import ListingsFeature

public enum ListingsMapper {
    public enum Error: Swift.Error, Equatable {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Listing] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else { throw Error.invalidData }
        return try root.results.map(listing(from:))
    }
}

// MARK: - Remote to domain

private extension ListingsMapper {
    static func listing(from item: RemoteItem) throws -> Listing {
        let content = item.listing.localization.content
        guard let title = content?.text?.title else {
            throw Error.invalidData
        }
        return Listing(
            id: item.id,
            title: title,
            price: nil,
            address: address(from: item.listing.address),
            imageURL: imageURL(from: content?.attachments)
        )
    }

    static func address(from remote: RemoteAddress) -> Address {
        Address(
            street: remote.street,
            postalCode: remote.postalCode,
            locality: remote.locality
        )
    }

    static func imageURL(from attachments: [RemoteAttachment]?) -> URL? {
        attachments?
            .first(where: \.isImage)
            .flatMap(\.url)
            .flatMap(URL.init(string:))
    }
}

// MARK: - Remote representation

private extension ListingsMapper {
    struct Root: Decodable {
        let results: [RemoteItem]
    }

    struct RemoteItem: Decodable {
        let id: String
        let listing: RemoteListing
    }

    struct RemoteListing: Decodable {
        let address: RemoteAddress
        let localization: RemoteLocalization
    }

    struct RemoteAddress: Decodable {
        let street: String?
        let postalCode: String?
        let locality: String
    }

    struct RemoteLocalization: Decodable {
        let content: RemoteContent?

        private struct Key: CodingKey {
            let stringValue: String
            var intValue: Int? { nil }
            init(_ stringValue: String) { self.stringValue = stringValue }
            init?(stringValue: String) { self.stringValue = stringValue }
            init?(intValue: Int) { nil }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Key.self)
            let primaryKey = Key(try container.decode(String.self, forKey: Key("primary")))
            let fallbackKey = container.allKeys.first { $0.stringValue != "primary" }
            let key = container.contains(primaryKey) ? primaryKey : fallbackKey
            content = try key.map { try container.decode(RemoteContent.self, forKey: $0) }
        }
    }

    struct RemoteContent: Decodable {
        let attachments: [RemoteAttachment]?
        let text: RemoteText?
    }

    struct RemoteAttachment: Decodable {
        static let imageType = "IMAGE"

        let type: String
        let url: String?

        var isImage: Bool { type == Self.imageType }
    }

    struct RemoteText: Decodable {
        let title: String?
    }
}
