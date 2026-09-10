import SwiftUI

public enum DesignSystemStrings {
    public static var errorTitle: Text { localized("error.title") }
    public static var errorRetry: Text { localized("error.retry") }
    public static var likeLabel: Text { localized("like.label") }
    public static var likeValueOn: Text { localized("like.value.on") }
    public static var likeValueOff: Text { localized("like.value.off") }

    private static func localized(_ key: LocalizedStringKey) -> Text {
        Text(key, bundle: .module)
    }
}

public enum DesignSystemResources {
    public static let bundle = Bundle.module
}
