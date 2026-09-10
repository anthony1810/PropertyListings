public struct Settings: Equatable, Sendable {
    public var appearance: Appearance
    public var language: AppLanguage

    public init(appearance: Appearance, language: AppLanguage) {
        self.appearance = appearance
        self.language = language
    }
}
