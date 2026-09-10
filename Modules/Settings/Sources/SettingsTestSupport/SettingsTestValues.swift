import SettingsFeature

public func makeSettings(
    appearance: Appearance = .system,
    language: AppLanguage = .english
) -> Settings {
    Settings(appearance: appearance, language: language)
}
