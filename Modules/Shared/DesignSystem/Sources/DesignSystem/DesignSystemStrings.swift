import Foundation

public enum DesignSystemStrings {
    public static var errorTitle: String { localized("error.title") }
    public static var errorRetry: String { localized("error.retry") }
    public static var likeLabel: String { localized("like.label") }
    public static var likeValueOn: String { localized("like.value.on") }
    public static var likeValueOff: String { localized("like.value.off") }

    private static func localized(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: .module)
    }
}

public enum DesignSystemResources {
    public static let bundle = Bundle.module
}
