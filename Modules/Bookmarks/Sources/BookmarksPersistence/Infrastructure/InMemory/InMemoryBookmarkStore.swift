public actor InMemoryBookmarkStore: BookmarkStore {
    private var bookmarks: [LocalBookmark]

    public init(bookmarks: [LocalBookmark] = []) {
        self.bookmarks = bookmarks
    }

    public func retrieve() async throws -> [LocalBookmark] {
        bookmarks
    }

    public func insert(_ bookmark: LocalBookmark) async throws {
        bookmarks.removeAll { $0.id == bookmark.id }
        bookmarks.append(bookmark)
    }

    public func delete(id: String) async throws {
        bookmarks.removeAll { $0.id == id }
    }
}
