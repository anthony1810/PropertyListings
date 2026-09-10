import SwiftUI

public enum ListingsUIStrings {
    public static var title: Text { localized("listings.title") }
    public static var emptyTitle: Text { localized("listings.empty.title") }
    public static var emptyHint: Text { localized("listings.empty.hint") }

    private static func localized(_ key: LocalizedStringKey) -> Text {
        Text(key, bundle: ListingsUIResources.bundle)
    }
}

public enum ListingsUIResources {
    public static let bundle = Bundle.module
}
