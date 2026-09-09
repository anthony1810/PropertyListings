public enum BookmarksAccessibilityID {
    public static let list = "bookmarks.list"
    public static let empty = "bookmarks.empty"
    public static let browse = "bookmarks.browse"

    public static func row(_ id: String) -> String {
        "bookmark.row.\(id)"
    }

    public static func like(_ id: String) -> String {
        "bookmark.like.\(id)"
    }
}
