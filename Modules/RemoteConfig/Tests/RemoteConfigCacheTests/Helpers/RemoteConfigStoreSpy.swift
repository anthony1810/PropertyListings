import Foundation
import RemoteConfigCache
import TestSupport

final class RemoteConfigStoreSpy: RemoteConfigStore, Sendable {
    enum Message: Equatable {
        case retrieve
        case insert(LocalRemoteConfig, Date)
    }

    let retrievalStub = Stub<CachedRemoteConfig?>()
    let insertionStub = Stub<Void>(.success(()))

    private let _receivedMessages = LockIsolated<[Message]>([])

    var receivedMessages: [Message] { _receivedMessages.value }

    func completeRetrieval(with cached: CachedRemoteConfig?) {
        retrievalStub.complete(with: .success(cached))
    }

    func completeRetrieval(with error: Error) {
        retrievalStub.complete(with: .failure(error))
    }

    func completeInsertion(with error: Error) {
        insertionStub.complete(with: .failure(error))
    }

    func retrieve() async throws -> CachedRemoteConfig? {
        _receivedMessages.withValue { $0.append(.retrieve) }
        return try await retrievalStub.call()
    }

    func insert(_ configuration: LocalRemoteConfig, timestamp: Date) async throws {
        _receivedMessages.withValue { $0.append(.insert(configuration, timestamp)) }
        try await insertionStub.call()
    }
}
