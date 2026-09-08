import Foundation
import ListingsFeature
import TestSupport

final class ListingsLoaderSpy: Sendable {
    enum Message: Equatable {
        case loadListings
        case notify(String)
    }

    private let _receivedMessages = LockIsolated<[Message]>([])
    private let _listingsResult = LockIsolated<Result<[Listing], Error>?>(nil)
    private let _onLoadListings = LockIsolated<(@MainActor @Sendable () -> Void)?>(nil)

    var receivedMessages: [Message] { _receivedMessages.value }

    func completeListings(with result: Result<[Listing], Error>) {
        _listingsResult.setValue(result)
    }

    func onNextLoadListings(_ observe: @escaping @MainActor @Sendable () -> Void) {
        _onLoadListings.setValue(observe)
    }

    @Sendable func loadListings() async throws -> [Listing] {
        _receivedMessages.withValue { $0.append(.loadListings) }
        if let observe = _onLoadListings.value {
            _onLoadListings.setValue(nil)
            await observe()
        }
        return try _listingsResult.value.evaluate()
    }

    @MainActor func notify(_ message: String) {
        _receivedMessages.withValue { $0.append(.notify(message)) }
    }
}
