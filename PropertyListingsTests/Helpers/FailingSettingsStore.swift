import SettingsPersistence

struct FailingSettingsStore: SettingsStore {
    struct Failure: Error {}

    let settings: LocalSettings?

    func retrieve() async throws -> LocalSettings? {
        settings
    }

    func insert(_ settings: LocalSettings) async throws {
        throw Failure()
    }
}
