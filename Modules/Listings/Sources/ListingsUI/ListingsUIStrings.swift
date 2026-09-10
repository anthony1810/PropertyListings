import SharedPresentation
import SwiftUI

public enum ListingsUIStrings {
    public static func title(for locale: Locale) -> String {
        String(localized: "listings.title", bundle: ListingsUIResources.bundle.localized(for: locale))
    }

    public static var emptyTitle: Text { localized("listings.empty.title") }
    public static var emptyHint: Text { localized("listings.empty.hint") }

    private static func localized(_ key: LocalizedStringKey) -> Text {
        Text(key, bundle: ListingsUIResources.bundle)
    }
}

public enum ListingsUIResources {
    public static let bundle = Bundle.module
}
