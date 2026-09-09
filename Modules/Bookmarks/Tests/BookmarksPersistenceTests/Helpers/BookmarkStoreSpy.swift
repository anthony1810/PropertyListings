import BookmarksPersistence
import TestSupport

final class BookmarkStoreSpy: BookmarkStore, Sendable {
    enum Message: Equatable {
        case retrieve
        case insert(LocalBookmark)
        case delete(String)
    }

    let retrievalStub = Stub<[LocalBookmark]>(.success([]))
    let insertionStub = Stub<Void>(.success(()))
    let deletionStub = Stub<Void>(.success(()))

    private let _receivedMessages = LockIsolated<[Message]>([])

    var receivedMessages: [Message] { _receivedMessages.value }

    func retrieve() async throws -> [LocalBookmark] {
        _receivedMessages.withValue { $0.append(.retrieve) }
        return try await retrievalStub.call()
    }

    func insert(_ bookmark: LocalBookmark) async throws {
        _receivedMessages.withValue { $0.append(.insert(bookmark)) }
        try await insertionStub.call()
    }

    func delete(id: String) async throws {
        _receivedMessages.withValue { $0.append(.delete(id)) }
        try await deletionStub.call()
    }
}
