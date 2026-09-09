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

    public static let toggleDebounce: Duration = .milliseconds(300)

    public private(set) var rows: [ListingRow] = []
    public private(set) var isLoading = false
    public private(set) var isLoadingMore = false
    public private(set) var loadFailureMessage: String?

    private var page = Paginated<Listing>(items: [])
    private var listings: [Listing] { page.items }
    private var bookmarkedIDs: Set<Listing.ID> = []
    private var pendingToggles: [Listing.ID: Task<Void, Never>] = [:]
    private var toggleBaselines: [Listing.ID: Bool] = [:]

    private let loadListings: @Sendable () async throws -> Paginated<Listing>
    private let observeBookmarkedIDs: @Sendable () -> any AsyncSequence<Set<Listing.ID>, Never>
    private let saveBookmark: @Sendable (Listing) async throws -> Void
    private let removeBookmark: @Sendable (Listing.ID) async throws -> Void
    private let notify: @MainActor (String) -> Void
    private let locale: Locale
    private let clock: any Clock<Duration>

    public init(
        loadListings: @Sendable @escaping () async throws -> Paginated<Listing>,
        observeBookmarkedIDs: @Sendable @escaping () -> any AsyncSequence<Set<Listing.ID>, Never>,
        saveBookmark: @Sendable @escaping (Listing) async throws -> Void,
        removeBookmark: @Sendable @escaping (Listing.ID) async throws -> Void,
        notify: @MainActor @escaping (String) -> Void,
        locale: Locale,
        clock: any Clock<Duration>
    ) {
        self.loadListings = loadListings
        self.observeBookmarkedIDs = observeBookmarkedIDs
        self.saveBookmark = saveBookmark
        self.removeBookmark = removeBookmark
        self.notify = notify
        self.locale = locale
        self.clock = clock
    }

    public var canLoadMore: Bool {
        page.loadMore != nil
    }

    public func loadMore() async {
        guard let loadMore = page.loadMore, !isLoadingMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            page = try await loadMore()
            rebuildRows()
        } catch {
            notify(Message.listingsFailed)
        }
    }

    public func toggleBookmark(id: Listing.ID) {
        guard let listing = listings.first(where: { $0.id == id }) else { return }
        if toggleBaselines[id] == nil {
            toggleBaselines[id] = bookmarkedIDs.contains(id)
        }
        bookmarkedIDs.formSymmetricDifference([id])
        rebuildRows()

        pendingToggles[id]?.cancel()
        pendingToggles[id] = Task { [weak self, clock] in
            guard (try? await clock.sleep(for: Self.toggleDebounce)) != nil else { return }
            await self?.persistBookmark(for: listing)
        }
    }

    public func observeBookmarks() async {
        for await ids in observeBookmarkedIDs() {
            bookmarkedIDs = ids
            rebuildRows()
        }
    }

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            page = try await loadListings()
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

// MARK: - Bookmark persistence

private extension ListingsViewModel {
    func persistBookmark(for listing: Listing) async {
        let id = listing.id
        pendingToggles[id] = nil
        guard let baseline = toggleBaselines.removeValue(forKey: id) else { return }
        let isBookmarked = bookmarkedIDs.contains(id)
        guard isBookmarked != baseline else { return }

        do {
            if isBookmarked {
                try await saveBookmark(listing)
            } else {
                try await removeBookmark(id)
            }
        } catch {
            if baseline {
                bookmarkedIDs.insert(id)
            } else {
                bookmarkedIDs.remove(id)
            }
            rebuildRows()
            notify(Message.bookmarkNotSaved)
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
