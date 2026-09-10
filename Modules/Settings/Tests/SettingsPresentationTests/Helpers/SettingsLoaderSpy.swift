import Foundation
import SettingsFeature
import TestSupport

final class SettingsLoaderSpy: Sendable {
    enum Message: Equatable {
        case observeSettings
        case saveSettings(Settings)
        case notify(String)
    }

    let saveSettingsStub = Stub<Void>(.success(()))

    private let _receivedMessages = LockIsolated<[Message]>([])
    private let settings = AsyncStream<Settings>.makeStream()

    var receivedMessages: [Message] { _receivedMessages.value }

    func emitSettings(_ settings: Settings) {
        self.settings.continuation.yield(settings)
    }

    @Sendable func observeSettings() -> any AsyncSequence<Settings, Never> {
        _receivedMessages.withValue { $0.append(.observeSettings) }
        return settings.stream
    }

    @Sendable func saveSettings(_ settings: Settings) async throws {
        _receivedMessages.withValue { $0.append(.saveSettings(settings)) }
        try await saveSettingsStub.call()
    }

    @MainActor func notify(_ message: String) {
        _receivedMessages.withValue { $0.append(.notify(message)) }
    }
}
