import Foundation

actor InMemoryBookmarkedIDs {
    private var ids: Set<String> = []
    private var continuations: [UUID: AsyncStream<Set<String>>.Continuation] = [:]

    func insert(_ id: String) {
        ids.insert(id)
        broadcast()
    }

    func remove(_ id: String) {
        ids.remove(id)
        broadcast()
    }

    nonisolated func observe() -> AsyncStream<Set<String>> {
        AsyncStream { continuation in
            let key = UUID()
            Task { await self.register(key: key, continuation: continuation) }
            continuation.onTermination = { _ in
                Task { await self.unregister(key: key) }
            }
        }
    }

    private func broadcast() {
        continuations.values.forEach { $0.yield(ids) }
    }

    private func register(key: UUID, continuation: AsyncStream<Set<String>>.Continuation) {
        continuations[key] = continuation
        continuation.yield(ids)
    }

    private func unregister(key: UUID) {
        continuations[key] = nil
    }
}
