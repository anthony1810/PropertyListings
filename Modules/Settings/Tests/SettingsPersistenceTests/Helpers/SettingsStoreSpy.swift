import SettingsPersistence
import TestSupport

final class SettingsStoreSpy: SettingsStore, Sendable {
    enum Message: Equatable {
        case retrieve
        case insert(LocalSettings)
    }

    let retrievalStub = Stub<LocalSettings?>(.success(nil))
    let insertionStub = Stub<Void>(.success(()))

    private let _receivedMessages = LockIsolated<[Message]>([])

    var receivedMessages: [Message] { _receivedMessages.value }

    func retrieve() async throws -> LocalSettings? {
        _receivedMessages.withValue { $0.append(.retrieve) }
        return try await retrievalStub.call()
    }

    func insert(_ settings: LocalSettings) async throws {
        _receivedMessages.withValue { $0.append(.insert(settings)) }
        try await insertionStub.call()
    }
}
