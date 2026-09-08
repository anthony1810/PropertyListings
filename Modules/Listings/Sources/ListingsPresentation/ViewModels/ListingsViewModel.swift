import Foundation
import ListingsFeature
import Observation

@Observable
@MainActor
public final class ListingsViewModel {
    public enum Message {
        public static var listingsFailed: String {
            String(localized: "listings.loadFailed", bundle: ListingsPresentationResources.bundle)
        }

        public static var bookmarkNotSaved: String {
            String(localized: "bookmarks.saveFailed", bundle: ListingsPresentationResources.bundle)
        }
    }

    public private(set) var rows: [ListingRow] = []
    public private(set) var isLoading = false
    public private(set) var loadFailureMessage: String?

    private var listings: [Listing] = []
    private var bookmarkedIDs: Set<Listing.ID> = []

    private let loadListings: @Sendable () async throws -> [Listing]
    private let observeBookmarkedIDs: @Sendable () -> any AsyncSequence<Set<Listing.ID>, Never>
    private let saveBookmark: @Sendable (Listing) async throws -> Void
    private let removeBookmark: @Sendable (Listing.ID) async throws -> Void
    private let notify: @MainActor (String) -> Void
    private let locale: Locale

    public init(
        loadListings: @Sendable @escaping () async throws -> [Listing],
        observeBookmarkedIDs: @Sendable @escaping () -> any AsyncSequence<Set<Listing.ID>, Never>,
        saveBookmark: @Sendable @escaping (Listing) async throws -> Void,
        removeBookmark: @Sendable @escaping (Listing.ID) async throws -> Void,
        notify: @MainActor @escaping (String) -> Void,
        locale: Locale
    ) {
        self.loadListings = loadListings
        self.observeBookmarkedIDs = observeBookmarkedIDs
        self.saveBookmark = saveBookmark
        self.removeBookmark = removeBookmark
        self.notify = notify
        self.locale = locale
    }

    public func toggleBookmark(id: Listing.ID) async {
        guard let listing = listings.first(where: { $0.id == id }) else { return }
        let previous = bookmarkedIDs
        let wasBookmarked = previous.contains(id)
        bookmarkedIDs.formSymmetricDifference([id])
        rebuildRows()

        do {
            if wasBookmarked {
                try await removeBookmark(id)
            } else {
                try await saveBookmark(listing)
            }
        } catch {
            bookmarkedIDs = previous
            rebuildRows()
            notify(Message.bookmarkNotSaved)
        }
    }

    public func observeBookmarks() async {
        for await ids in observeBookmarkedIDs() {
            bookmarkedIDs = ids
            rebuildRows()
        }
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            listings = try await loadListings()
            loadFailureMessage = nil
            rebuildRows()
        } catch {
            if listings.isEmpty {
                loadFailureMessage = Message.listingsFailed
            } else {
                notify(Message.listingsFailed)
            }
        }
    }
}

// MARK: - Rows

private extension ListingsViewModel {
    func rebuildRows() {
        rows = listings.map {
            ListingRowMapper.map($0, isBookmarked: bookmarkedIDs.contains($0.id), locale: locale)
        }
    }
}
