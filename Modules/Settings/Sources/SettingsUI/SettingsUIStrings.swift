#if canImport(UIKit)
import SettingsFeature
import SharedPresentation
import SwiftUI

public enum SettingsUIStrings {
    public static func title(for locale: Locale) -> String {
        String(localized: "settings.title", bundle: SettingsUIResources.bundle.localized(for: locale))
    }

    public static var appearance: Text { localized("settings.appearance") }
    public static var language: Text { localized("settings.language") }

    public static func label(for appearance: Appearance) -> Text {
        switch appearance {
        case .system: localized("settings.appearance.system")
        case .light: localized("settings.appearance.light")
        case .dark: localized("settings.appearance.dark")
        }
    }

    private static func localized(_ key: LocalizedStringKey) -> Text {
        Text(key, bundle: SettingsUIResources.bundle)
    }
}

public enum SettingsUIResources {
    public static let bundle = Bundle.module
}
#endif
