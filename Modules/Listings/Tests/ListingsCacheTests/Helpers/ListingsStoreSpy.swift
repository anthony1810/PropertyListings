import Foundation
import ListingsCache
import TestSupport

final class ListingsStoreSpy: ListingsStore, Sendable {
    enum Message: Equatable {
        case retrieve
        case insert([LocalListing], Date)
        case deleteCachedListings
    }

    let retrievalStub = Stub<CachedListings?>()
    let insertionStub = Stub<Void>(.success(()))
    let deletionStub = Stub<Void>(.success(()))

    private let _receivedMessages = LockIsolated<[Message]>([])

    var receivedMessages: [Message] { _receivedMessages.value }

    func completeRetrieval(with cached: CachedListings?) {
        retrievalStub.complete(with: .success(cached))
    }

    func completeRetrieval(with error: Error) {
        retrievalStub.complete(with: .failure(error))
    }

    func completeInsertion(with error: Error) {
        insertionStub.complete(with: .failure(error))
    }

    func completeDeletion(with error: Error) {
        deletionStub.complete(with: .failure(error))
    }

    func retrieve() async throws -> CachedListings? {
        _receivedMessages.withValue { $0.append(.retrieve) }
        return try await retrievalStub.call()
    }

    func insert(_ listings: [LocalListing], timestamp: Date) async throws {
        _receivedMessages.withValue { $0.append(.insert(listings, timestamp)) }
        try await insertionStub.call()
    }

    func deleteCachedListings() async throws {
        _receivedMessages.withValue { $0.append(.deleteCachedListings) }
        try await deletionStub.call()
    }
}
