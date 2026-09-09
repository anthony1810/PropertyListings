public protocol SettingsStore: Sendable {
    func retrieve() async throws -> LocalSettings?
    func insert(_ settings: LocalSettings) async throws
}
