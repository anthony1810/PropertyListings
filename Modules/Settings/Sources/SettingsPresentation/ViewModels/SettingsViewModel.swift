import Foundation
import Observation
import SettingsFeature
import SharedPresentation

@Observable
@MainActor
public final class SettingsViewModel {
    public enum Message {
        public static func saveFailed(_ locale: Locale) -> String {
            String(localized: "settings.saveFailed", bundle: SettingsPresentationResources.bundle.localized(for: locale))
        }
    }

    public static let debounce: Duration = .milliseconds(300)

    public private(set) var settings: Settings
    public private(set) var appliedSettings: Settings
    public private(set) var locale: Locale

    private var pendingCommit: Task<Void, Never>?
    private var baseline: Settings?

    private let observeSettings: @Sendable () -> any AsyncSequence<Settings, Never>
    private let saveSettings: @Sendable (Settings) async throws -> Void
    private let notify: @MainActor (String) -> Void
    private let clock: any Clock<Duration>

    public init(
        initial: Settings,
        observeSettings: @Sendable @escaping () -> any AsyncSequence<Settings, Never>,
        saveSettings: @Sendable @escaping (Settings) async throws -> Void,
        notify: @MainActor @escaping (String) -> Void,
        locale: Locale,
        clock: any Clock<Duration>
    ) {
        settings = initial
        appliedSettings = initial
        self.observeSettings = observeSettings
        self.saveSettings = saveSettings
        self.notify = notify
        self.locale = locale
        self.clock = clock
    }

    public func observe() async {
        for await settings in observeSettings() {
            guard pendingCommit == nil else { continue }
            self.settings = settings
            appliedSettings = settings
        }
    }

    public func select(appearance: Appearance) {
        choose(Settings(appearance: appearance, language: settings.language))
    }

    public func select(language: AppLanguage) {
        choose(Settings(appearance: settings.appearance, language: language))
    }

    public func update(locale: Locale) {
        self.locale = locale
    }
}

// MARK: - Choose and commit

private extension SettingsViewModel {
    func choose(_ chosen: Settings) {
        guard chosen != settings else { return }
        if baseline == nil {
            baseline = settings
        }
        settings = chosen
        pendingCommit?.cancel()
        pendingCommit = Task { [weak self, clock] in
            try? await clock.sleep(for: Self.debounce)
            guard !Task.isCancelled else { return }
            await self?.commit()
        }
    }

    func commit() async {
        pendingCommit = nil
        guard let previous = baseline else { return }
        baseline = nil
        let chosen = settings
        appliedSettings = chosen
        guard chosen != previous else { return }
        do {
            try await saveSettings(chosen)
        } catch {
            settings = previous
            appliedSettings = previous
            notify(Message.saveFailed(locale))
        }
    }
}
