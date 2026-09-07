import Foundation
import ListingsFeature

public enum ListingsMapper {
    public enum Error: Swift.Error, Equatable {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Listing] {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else { throw Error.invalidData }
        return try root.results.map(Listing.init(remote:))
    }

    // MARK: - Remote representation

    private struct Root: Decodable {
        let results: [RemoteItem]
    }

    fileprivate struct RemoteItem: Decodable {
        let id: String
        let listing: RemoteListing
    }

    fileprivate struct RemoteListing: Decodable {
        let address: RemoteAddress
        let localization: RemoteLocalization
    }

    fileprivate struct RemoteAddress: Decodable {
        let street: String?
        let postalCode: String?
        let locality: String
    }

    fileprivate struct RemoteLocalization: Decodable {
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

    fileprivate struct RemoteContent: Decodable {
        let text: RemoteText?
    }

    fileprivate struct RemoteText: Decodable {
        let title: String?
    }
}

private extension Listing {
    init(remote item: ListingsMapper.RemoteItem) throws {
        guard let title = item.listing.localization.content?.text?.title else {
            throw ListingsMapper.Error.invalidData
        }
        self.init(
            id: item.id,
            title: title,
            price: nil,
            address: Address(
                street: item.listing.address.street,
                postalCode: item.listing.address.postalCode,
                locality: item.listing.address.locality
            ),
            imageURL: nil
        )
    }
}
