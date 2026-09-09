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

    public private(set) var settings: Settings
    public private(set) var locale: Locale

    private let observeSettings: @Sendable () -> any AsyncSequence<Settings, Never>
    private let saveSettings: @Sendable (Settings) async throws -> Void
    private let notify: @MainActor (String) -> Void

    public init(
        initial: Settings,
        observeSettings: @Sendable @escaping () -> any AsyncSequence<Settings, Never>,
        saveSettings: @Sendable @escaping (Settings) async throws -> Void,
        notify: @MainActor @escaping (String) -> Void,
        locale: Locale
    ) {
        settings = initial
        self.observeSettings = observeSettings
        self.saveSettings = saveSettings
        self.notify = notify
        self.locale = locale
    }

    public func observe() async {
        for await settings in observeSettings() {
            self.settings = settings
        }
    }

    public func select(appearance: Appearance) async {
        await apply(Settings(appearance: appearance, language: settings.language))
    }

    public func select(language: AppLanguage) async {
        await apply(Settings(appearance: settings.appearance, language: language))
    }

    public func update(locale: Locale) {
        self.locale = locale
    }
}

// MARK: - Apply

private extension SettingsViewModel {
    func apply(_ chosen: Settings) async {
        let previous = settings
        guard chosen != previous else { return }
        settings = chosen
        do {
            try await saveSettings(chosen)
        } catch {
            settings = previous
            notify(Message.saveFailed(locale))
        }
    }
}
