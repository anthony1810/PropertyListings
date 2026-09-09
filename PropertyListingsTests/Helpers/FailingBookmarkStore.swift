import BookmarksPersistence

struct FailingBookmarkStore: BookmarkStore {
    struct Failure: Error {}

    func retrieve() async throws -> [LocalBookmark] {
        []
    }

    func insert(_ bookmark: LocalBookmark) async throws {
        throw Failure()
    }

    func delete(id: String) async throws {
        throw Failure()
    }
}
