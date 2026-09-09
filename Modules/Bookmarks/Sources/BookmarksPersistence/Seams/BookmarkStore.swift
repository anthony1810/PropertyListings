public protocol BookmarkStore: Sendable {
    func retrieve() async throws -> [LocalBookmark]
    func insert(_ bookmark: LocalBookmark) async throws
    func delete(id: String) async throws
}
