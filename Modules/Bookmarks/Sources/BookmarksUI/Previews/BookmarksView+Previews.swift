#if DEBUG && canImport(UIKit)
import BookmarksFeature
import BookmarksPresentation
import Foundation

extension BookmarksViewModel {
    static func preview(bookmarks: [Bookmark] = Bookmark.previews) -> BookmarksViewModel {
        BookmarksViewModel(
            observeBookmarks: { AsyncStream { $0.yield(bookmarks) } },
            removeBookmark: { _ in },
            notify: { _ in },
            locale: Locale(identifier: "de_CH")
        )
    }
}

extension Bookmark {
    static let previews: [Bookmark] = [
        Bookmark(
            id: "1",
            title: "Luxuriöses Einfamilienhaus mit Pool",
            price: Price(amount: 9_999_999, currency: "CHF"),
            address: Address(street: "Musterstrasse 999", postalCode: "2406", locality: "La Brévine"),
            imageURL: URL(string: "https://picsum.photos/seed/1/900/600"),
            savedAt: Date()
        ),
        Bookmark(
            id: "2",
            title: "Helle Wohnung im Zentrum",
            price: nil,
            address: Address(street: nil, postalCode: "8000", locality: "Zürich"),
            imageURL: URL(string: "https://picsum.photos/seed/2/900/600"),
            savedAt: Date()
        ),
    ]
}
#endif
