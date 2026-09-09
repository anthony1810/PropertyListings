import SwiftUI

public enum BookmarksUIStrings {
    public static var title: Text { localized("bookmarks.title") }
    public static var emptyTitle: Text { localized("bookmarks.empty.title") }
    public static var emptyHint: Text { localized("bookmarks.empty.hint") }
    public static var browse: Text { localized("bookmarks.empty.browse") }
    public static var remove: Text { localized("bookmarks.remove") }

    private static func localized(_ key: LocalizedStringKey) -> Text {
        Text(key, bundle: BookmarksUIResources.bundle)
    }
}

public enum BookmarksUIResources {
    public static let bundle = Bundle.module
}
