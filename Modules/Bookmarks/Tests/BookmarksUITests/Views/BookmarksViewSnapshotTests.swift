#if canImport(UIKit)
import BookmarksFeature
import BookmarksPresentation
import BookmarksTestSupport
import SnapshotTesting
import SwiftUI
import Testing
import TestSupport
@testable import BookmarksUI

@MainActor
@Suite struct BookmarksViewSnapshotTests {
    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func content_matchesTheReference(style: UIUserInterfaceStyle) async {
        let view = await makeView(bookmarks: sampleBookmarks)

        assert(view, style: style, testName: "content")
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func empty_matchesTheReference(style: UIUserInterfaceStyle) async {
        let view = await makeView(bookmarks: [])

        assert(view, style: style, testName: "empty")
    }

    // MARK: - Helpers

    private var sampleBookmarks: [Bookmark] {
        [
            makeBookmark(
                id: "1",
                title: "Luxuriöses Einfamilienhaus mit Pool",
                price: Price(amount: 9_999_999, currency: "CHF"),
                street: "Musterstrasse 999",
                postalCode: "2406",
                locality: "La Brévine",
                imageURL: nil
            ),
            makeBookmark(
                id: "2",
                title: "Grande maison en viager occupé sans rente",
                price: nil,
                street: nil,
                postalCode: "2406",
                locality: "La Brévine",
                imageURL: nil
            ),
        ]
    }

    private func makeView(bookmarks: [Bookmark]) async -> some View {
        let viewModel = BookmarksViewModel(
            observeBookmarks: { AsyncStream { $0.yield(bookmarks); $0.finish() } },
            removeBookmark: { _ in },
            notify: { _ in },
            locale: Locale(identifier: "de_CH")
        )
        await viewModel.observe()
        return NavigationStack { BookmarksView(viewModel: viewModel, onBrowseListings: {}) }
            .transaction { $0.animation = nil }
    }

    private func assert(_ view: some View, style: UIUserInterfaceStyle, testName: String) {
        assertSnapshot(
            of: view,
            as: .image(precision: 0.95, perceptualPrecision: 0.97, layout: .device(config: .iPhone17(style))),
            named: style.snapshotName,
            record: SnapshotHost.isRecording ? .all : nil,
            testName: testName
        )
    }
}
#endif
