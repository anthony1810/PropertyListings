#if DEBUG && canImport(UIKit)
import ListingsFeature
import ListingsPresentation
import SwiftUI

extension ListingsViewModel {
    static func preview(
        listings: [Listing] = Listing.previews,
        bookmarkedIDs: Set<Listing.ID> = [Listing.previews[0].id]
    ) -> ListingsViewModel {
        preview(loadListings: { Paginated(items: listings) }, bookmarkedIDs: bookmarkedIDs)
    }

    static func previewLoading() -> ListingsViewModel {
        preview(loadListings: { try await Task.sleep(for: .seconds(60)); return Paginated(items: []) })
    }

    static func previewFailing() -> ListingsViewModel {
        preview(loadListings: { throw PreviewError() })
    }

    private struct PreviewError: Error {}

    private static func preview(
        loadListings: @escaping @Sendable () async throws -> Paginated<Listing>,
        bookmarkedIDs: Set<Listing.ID> = []
    ) -> ListingsViewModel {
        ListingsViewModel(
            loadListings: loadListings,
            observeBookmarkedIDs: { AsyncStream { $0.yield(bookmarkedIDs) } },
            saveBookmark: { _ in },
            removeBookmark: { _ in },
            notify: { _ in },
            locale: Locale(identifier: "de_CH"),
            clock: ContinuousClock()
        )
    }
}

extension Listing {
    static let previews: [Listing] = [
        Listing(
            id: "1",
            title: "Luxuriöses Einfamilienhaus mit Pool",
            price: Price(amount: 9_999_999, currency: "CHF"),
            address: Address(street: "Musterstrasse 999", postalCode: "2406", locality: "La Brévine"),
            imageURL: URL(string: "https://picsum.photos/seed/1/900/600")
        ),
        Listing(
            id: "2",
            title: "Helle Wohnung im Zentrum",
            price: nil,
            address: Address(street: nil, postalCode: "8000", locality: "Zürich"),
            imageURL: URL(string: "https://picsum.photos/seed/2/900/600")
        ),
    ]
}
#endif
