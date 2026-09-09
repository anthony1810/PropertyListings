import DesignSystem
import Foundation
import HTTPClient
import HTTPClientLive
import ListingsCache
import ListingsFeature
import ListingsPresentation
import ListingsUI

@MainActor
final class AppComposition {
    let router = AppRouter()

    // MARK: - Edges

    private lazy var httpClient: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    private lazy var listingsStore: ListingsStore = CodableListingsStore(storeURL: Self.storeURL(named: "listings.json"))
    private var currentDate: @Sendable () -> Date = Date.init
    private var locale: Locale = .current
    private var clock: any Clock<Duration> = ContinuousClock()

    // MARK: - Services

    private lazy var listingsService = ListingsService(
        httpClient: httpClient,
        store: listingsStore,
        baseURL: ServiceURLs.listings,
        currentDate: currentDate
    )
    private let bookmarkedIDs = InMemoryBookmarkedIDs()

    // MARK: - Init

    init() {
        ImagePipeline.configure()
    }

    convenience init(httpClient: HTTPClient) {
        self.init()
        self.httpClient = httpClient
    }

    convenience init(
        httpClient: HTTPClient,
        listingsStore: ListingsStore,
        currentDate: @escaping @Sendable () -> Date,
        locale: Locale,
        clock: any Clock<Duration> = ContinuousClock()
    ) {
        self.init()
        self.httpClient = httpClient
        self.listingsStore = listingsStore
        self.currentDate = currentDate
        self.locale = locale
        self.clock = clock
    }

    // MARK: - Launch

    func validateCache() async {
        await listingsService.validateCache()
    }
}

// MARK: - Listings

extension AppComposition {
    func makeListingsView() -> ListingsView {
        ListingsView(viewModel: makeListingsViewModel())
    }

    func makeListingsViewModel() -> ListingsViewModel {
        let service = listingsService
        let bookmarkedIDs = bookmarkedIDs
        let router = router
        return ListingsViewModel(
            loadListings: { try await service.loadListings() },
            observeBookmarkedIDs: { bookmarkedIDs.observe() },
            saveBookmark: { await bookmarkedIDs.insert($0.id) },
            removeBookmark: { await bookmarkedIDs.remove($0) },
            notify: { router.present(.error($0)) },
            locale: locale,
            clock: clock
        )
    }
}

// MARK: - Storage

extension AppComposition {
    static let storageDirectory = URL.applicationSupportDirectory.appending(path: "PropertyListings", directoryHint: .isDirectory)

    private static func storeURL(named fileName: String) -> URL {
        try? FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        return storageDirectory.appending(path: fileName)
    }
}
