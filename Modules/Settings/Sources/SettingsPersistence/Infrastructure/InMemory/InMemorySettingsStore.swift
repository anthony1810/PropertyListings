public actor InMemorySettingsStore: SettingsStore {
    private var settings: LocalSettings?

    public init(settings: LocalSettings? = nil) {
        self.settings = settings
    }

    public func retrieve() async throws -> LocalSettings? {
        settings
    }

    public func insert(_ settings: LocalSettings) async throws {
        self.settings = settings
    }
}
