import Foundation

extension HTTPURLResponse {
    private static let ok = 200

    var isOK: Bool {
        statusCode == Self.ok
    }
}
