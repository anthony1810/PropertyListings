import BookmarksFeature
import Foundation
import Observation

@Observable
@MainActor
public final class BookmarksViewModel {
    public enum Message {
        public static var removeFailed: String {
            String(localized: "bookmarks.removeFailed", bundle: BookmarksPresentationResources.bundle)
        }
    }

    public private(set) var rows: [BookmarkRow] = []

    private var bookmarks: [Bookmark] = []
    private var removalsInFlight: Set<Bookmark.ID> = []

    private let observeBookmarks: @Sendable () -> any AsyncSequence<[Bookmark], Never>
    private let removeBookmark: @Sendable (Bookmark.ID) async throws -> Void
    private let notify: @MainActor (String) -> Void
    private let locale: Locale

    public init(
        observeBookmarks: @Sendable @escaping () -> any AsyncSequence<[Bookmark], Never>,
        removeBookmark: @Sendable @escaping (Bookmark.ID) async throws -> Void,
        notify: @MainActor @escaping (String) -> Void,
        locale: Locale
    ) {
        self.observeBookmarks = observeBookmarks
        self.removeBookmark = removeBookmark
        self.notify = notify
        self.locale = locale
    }

    public func remove(id: Bookmark.ID) async {
        guard let index = bookmarks.firstIndex(where: { $0.id == id }),
              !removalsInFlight.contains(id)
        else { return }
        removalsInFlight.insert(id)
        defer { removalsInFlight.remove(id) }
        let removed = bookmarks.remove(at: index)
        rebuildRows()

        do {
            try await removeBookmark(id)
        } catch {
            bookmarks.insert(removed, at: min(index, bookmarks.count))
            rebuildRows()
            notify(Message.removeFailed)
        }
    }

    public func observe() async {
        for await bookmarks in observeBookmarks() {
            self.bookmarks = bookmarks
            rebuildRows()
        }
    }
}

// MARK: - Rows

private extension BookmarksViewModel {
    func rebuildRows() {
        rows = bookmarks.map { BookmarkRowMapper.map($0, locale: locale) }
    }
}
