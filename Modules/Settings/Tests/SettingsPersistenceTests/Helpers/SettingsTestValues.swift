import SettingsFeature
import SettingsPersistence
import SettingsTestSupport

func makeSettingsPair(
    appearance: Appearance = .system,
    language: AppLanguage = .english
) -> (model: Settings, local: LocalSettings) {
    let model = makeSettings(appearance: appearance, language: language)
    let local = LocalSettings(appearance: model.appearance.rawValue, language: model.language.rawValue)
    return (model, local)
}

func makeLocalSettings(
    appearance: Appearance = .system,
    language: AppLanguage = .english
) -> LocalSettings {
    makeSettingsPair(appearance: appearance, language: language).local
}
