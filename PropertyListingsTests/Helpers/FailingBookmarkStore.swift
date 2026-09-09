import BookmarksFeature
import BookmarksPersistence

struct FailingBookmarkStore: BookmarkStore {
    struct Failure: Error {}

    private let bookmarks: [LocalBookmark]

    init(bookmarks: [Bookmark] = []) {
        self.bookmarks = bookmarks.map(LocalBookmark.init(bookmark:))
    }

    func retrieve() async throws -> [LocalBookmark] {
        bookmarks
    }

    func insert(_ bookmark: LocalBookmark) async throws {
        throw Failure()
    }

    func delete(id: String) async throws {
        throw Failure()
    }
}
