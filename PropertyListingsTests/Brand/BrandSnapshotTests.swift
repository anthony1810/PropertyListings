import BookmarksFeature
import BookmarksPersistence
import BookmarksTestSupport
import DesignSystem
import ListingsAPI
import SnapshotTesting
import SwiftUI
import Testing
import TestSupport
@testable import PropertyListings

@MainActor
@Suite struct BrandSnapshotTests {
    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func root_matchesTheBrandReference(style: UIUserInterfaceStyle) async {
        let app = launch(online)
        await app.listings.load()

        assert(
            RootView(composition: app.composition),
            style: style,
            testName: "root",
            inKeyWindow: true
        )
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func listings_matchTheBrandReference(style: UIUserInterfaceStyle) async {
        let app = launch(
            online,
            bookmarks: [makeBookmark(id: house.model.id, title: house.model.title, savedAt: now)]
        )
        await app.listings.load()

        await app.observingBookmarks {
            assert(
                NavigationStack { app.composition.makeListingsView() },
                style: style,
                testName: "listings"
            )
        }
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func saved_matchTheBrandReference(style: UIUserInterfaceStyle) async {
        let app = launch(
            .offline,
            bookmarks: [makeBookmark(id: "1", title: "Haus am See", savedAt: now)]
        )

        await app.observingBookmarks {
            assert(
                NavigationStack { app.composition.makeBookmarksView() },
                style: style,
                testName: "saved"
            )
        }
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func settings_matchTheBrandReference(style: UIUserInterfaceStyle) async {
        let app = launch(.offline)

        assert(
            NavigationStack { app.composition.makeSettingsView() },
            style: style,
            testName: "settings"
        )
    }

    // MARK: - Helpers

    private let brand = CurrentBrand.configuration
    private let now = Date()
    private let clock = TestClock()
    private let deCH = Locale(identifier: "de_CH")
    private let house = makeRemoteListing(
        id: "1",
        title: "Haus am See",
        price: 1_250_000,
        street: "Seestrasse 12",
        locality: "Zürich"
    )
    private let flat = makeRemoteListing(
        id: "2",
        title: "Wohnung mit Balkon",
        price: nil,
        street: nil,
        locality: "Bern"
    )

    private var brandName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "unknown"
    }

    private var listingsURL: URL {
        ListingsEndpoint.page(from: 0, size: brand.listings.pageSize).url(
            baseURL: brand.listings.host
        )
    }

    private var online: HTTPClientStub {
        HTTPClientStub([listingsURL: [.success(makeItemsJSON([house.json, flat.json]))]])
    }

    private func launch(_ client: HTTPClientStub, bookmarks: [Bookmark] = []) -> AcceptanceApp {
        let stores = AcceptanceApp.Stores(
            bookmarks: InMemoryBookmarkStore(
                bookmarks: bookmarks.map(LocalBookmark.init(bookmark:))
            )
        )
        return AcceptanceApp(
            client: client,
            stores: stores,
            today: LockIsolated(now),
            locale: deCH,
            clock: clock,
            brand: brand
        )
    }

    private func assert(
        _ view: some View,
        style: UIUserInterfaceStyle,
        testName: String,
        inKeyWindow: Bool = false,
        filePath: StaticString = #filePath,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        DSTokens.configure(
            brand: DSBrand(
                bundle: .main,
                radii: brand.design.radii,
                typeface: brand.design.typeface
            )
        )
        let failure = verifySnapshot(
            of: view.transaction { $0.animation = nil },
            as: .image(
                drawHierarchyInKeyWindow: inKeyWindow,
                precision: 0.95,
                perceptualPrecision: 0.97,
                layout: .device(config: .iPhone17(style))
            ),
            named: style.snapshotName,
            record: SnapshotHost.isRecording ? .all : nil,
            snapshotDirectory: referenceDirectory(besides: filePath),
            testName: testName
        )
        #expect(failure == nil, Comment(rawValue: failure ?? ""), sourceLocation: sourceLocation)
    }

    private func referenceDirectory(besides filePath: StaticString) -> String {
        URL(fileURLWithPath: "\(filePath)", isDirectory: false)
            .deletingLastPathComponent()
            .appending(path: "__Snapshots__/BrandSnapshotTests/\(brandName)")
            .path
    }
}
