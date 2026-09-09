import Foundation

public enum BookmarksUIStrings {
    public static var title: String { localized("bookmarks.title") }
    public static var emptyTitle: String { localized("bookmarks.empty.title") }
    public static var emptyHint: String { localized("bookmarks.empty.hint") }
    public static var browse: String { localized("bookmarks.empty.browse") }
    public static var remove: String { localized("bookmarks.remove") }

    private static func localized(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: BookmarksUIResources.bundle)
    }
}

public enum BookmarksUIResources {
    public static let bundle = Bundle.module
}
