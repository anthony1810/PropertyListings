import Foundation
import RemoteConfigCache
import TestSupport

final class RemoteBrandStoreSpy: RemoteBrandStore, Sendable {
    enum Message: Equatable {
        case retrieve
        case insert(LocalRemoteBrand, Date)
    }

    let retrievalStub = Stub<CachedRemoteBrand?>()
    let insertionStub = Stub<Void>(.success(()))

    private let _receivedMessages = LockIsolated<[Message]>([])

    var receivedMessages: [Message] { _receivedMessages.value }

    func completeRetrieval(with cached: CachedRemoteBrand?) {
        retrievalStub.complete(with: .success(cached))
    }

    func completeRetrieval(with error: Error) {
        retrievalStub.complete(with: .failure(error))
    }

    func completeInsertion(with error: Error) {
        insertionStub.complete(with: .failure(error))
    }

    func retrieve() async throws -> CachedRemoteBrand? {
        _receivedMessages.withValue { $0.append(.retrieve) }
        return try await retrievalStub.call()
    }

    func insert(_ brand: LocalRemoteBrand, timestamp: Date) async throws {
        _receivedMessages.withValue { $0.append(.insert(brand, timestamp)) }
        try await insertionStub.call()
    }
}
