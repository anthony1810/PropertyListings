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

    private let observeBookmarks: @Sendable () -> any AsyncSequence<[Bookmark], Never>
    private let notify: @MainActor (String) -> Void
    private let locale: Locale

    public init(
        observeBookmarks: @Sendable @escaping () -> any AsyncSequence<[Bookmark], Never>,
        notify: @MainActor @escaping (String) -> Void,
        locale: Locale
    ) {
        self.observeBookmarks = observeBookmarks
        self.notify = notify
        self.locale = locale
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
