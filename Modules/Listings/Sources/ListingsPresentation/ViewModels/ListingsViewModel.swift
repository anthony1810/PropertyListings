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
    }

    public private(set) var rows: [ListingRow] = []
    public private(set) var isLoading = false
    public private(set) var loadFailureMessage: String?

    private var listings: [Listing] = []

    private let loadListings: @Sendable () async throws -> [Listing]
    private let notify: @MainActor (String) -> Void
    private let locale: Locale

    public init(
        loadListings: @Sendable @escaping () async throws -> [Listing],
        notify: @MainActor @escaping (String) -> Void,
        locale: Locale
    ) {
        self.loadListings = loadListings
        self.notify = notify
        self.locale = locale
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
        rows = listings.map { ListingRowMapper.map($0, isBookmarked: false, locale: locale) }
    }
}
