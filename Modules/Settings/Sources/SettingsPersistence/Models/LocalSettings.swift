public struct LocalSettings: Equatable, Sendable {
    public let appearance: String
    public let language: String

    public init(appearance: String, language: String) {
        self.appearance = appearance
        self.language = language
    }
}
