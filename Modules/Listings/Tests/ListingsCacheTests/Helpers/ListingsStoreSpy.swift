import Foundation
import ListingsCache
import TestSupport

final class ListingsStoreSpy: ListingsStore, Sendable {
    enum Message: Equatable {
        case retrieve
        case insert([LocalListing], Date)
        case deleteCachedListings
    }

    private let _receivedMessages = LockIsolated<[Message]>([])
    private let _retrievalResult = LockIsolated<Result<CachedListings?, Error>?>(nil)
    private let _insertionResult = LockIsolated<Result<Void, Error>?>(.success(()))
    private let _deletionResult = LockIsolated<Result<Void, Error>?>(.success(()))

    var receivedMessages: [Message] { _receivedMessages.value }

    func completeRetrieval(with cached: CachedListings?) {
        _retrievalResult.setValue(.success(cached))
    }

    func completeRetrieval(with error: Error) {
        _retrievalResult.setValue(.failure(error))
    }

    func completeInsertion(with error: Error) {
        _insertionResult.setValue(.failure(error))
    }

    func completeDeletion(with error: Error) {
        _deletionResult.setValue(.failure(error))
    }

    func retrieve() async throws -> CachedListings? {
        _receivedMessages.withValue { $0.append(.retrieve) }
        return try _retrievalResult.value.evaluate()
    }

    func insert(_ listings: [LocalListing], timestamp: Date) async throws {
        _receivedMessages.withValue { $0.append(.insert(listings, timestamp)) }
        try _insertionResult.value.evaluate()
    }

    func deleteCachedListings() async throws {
        _receivedMessages.withValue { $0.append(.deleteCachedListings) }
        try _deletionResult.value.evaluate()
    }
}
