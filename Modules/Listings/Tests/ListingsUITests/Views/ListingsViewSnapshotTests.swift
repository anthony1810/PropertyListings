#if canImport(UIKit)
import ListingsFeature
import ListingsPresentation
import ListingsTestSupport
import SnapshotTesting
import SwiftUI
import Testing
import TestSupport
@testable import ListingsUI

@MainActor
@Suite struct ListingsViewSnapshotTests {
    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func content_matchesTheReference(style: UIUserInterfaceStyle) async {
        let listings = sampleListings
        let view = await makeView(loadListings: { Paginated(items: listings) }, bookmarked: ["2"])

        assert(view, style: style, testName: "content")
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func loadingMore_matchesTheReference(style: UIUserInterfaceStyle) async {
        let listings = sampleListings
        let view = await makeView(loadListings: { Paginated(items: listings) { Paginated(items: []) } })

        assert(view, style: style, testName: "loadingMore")
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func loading_matchesTheReference(style: UIUserInterfaceStyle) async {
        let gate = Gate()
        let view = await makeView(loadListings: { await gate.wait(); return Paginated(items: []) }, awaitLoad: false)

        assert(view, style: style, testName: "loading")
        gate.open()
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func empty_matchesTheReference(style: UIUserInterfaceStyle) async {
        let view = await makeView(loadListings: { Paginated(items: []) })

        assert(view, style: style, testName: "empty")
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func error_matchesTheReference(style: UIUserInterfaceStyle) async {
        let view = await makeView(loadListings: { throw anyNSError() })

        assert(view, style: style, testName: "error")
    }

    // MARK: - Helpers

    private var sampleListings: [Listing] {
        [
            makeListing(
                id: "1",
                title: "Luxuriöses Einfamilienhaus mit Pool",
                price: Price(amount: 9_999_999, currency: "CHF"),
                street: "Musterstrasse 999",
                postalCode: "2406",
                locality: "La Brévine",
                imageURL: nil
            ),
            makeListing(
                id: "2",
                title: "Grande maison en viager occupé sans rente",
                price: Price(amount: 430_000, currency: "CHF"),
                street: nil,
                postalCode: "2406",
                locality: "La Brévine",
                imageURL: nil
            ),
            makeListing(
                id: "3",
                title: "Test listing",
                price: nil,
                street: nil,
                postalCode: nil,
                locality: "La Brévine",
                imageURL: nil
            ),
        ]
    }

    private func makeView(
        loadListings: @escaping @Sendable () async throws -> Paginated<Listing>,
        bookmarked: Set<Listing.ID> = [],
        awaitLoad: Bool = true
    ) async -> some View {
        let viewModel = ListingsViewModel(
            loadListings: loadListings,
            observeBookmarkedIDs: { AsyncStream { $0.yield(bookmarked); $0.finish() } },
            saveBookmark: { _ in },
            removeBookmark: { _ in },
            notify: { _ in },
            locale: Locale(identifier: "de_CH"),
            clock: ContinuousClock()
        )
        if awaitLoad {
            await viewModel.load()
        } else {
            Task { await viewModel.load() }
            await Task.megaYield()
        }
        await viewModel.observeBookmarks()
        return NavigationStack { ListingsView(viewModel: viewModel) }
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
