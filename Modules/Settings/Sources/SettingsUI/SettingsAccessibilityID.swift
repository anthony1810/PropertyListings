import SettingsFeature

public enum SettingsAccessibilityID {
    public static let list = "settings.list"
    public static let appearance = "settings.appearance"

    public static func language(_ language: AppLanguage) -> String {
        "settings.language.\(language.rawValue)"
    }
}
