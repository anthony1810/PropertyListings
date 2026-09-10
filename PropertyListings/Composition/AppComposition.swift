import BookmarksFeature
import BookmarksPersistence
import BookmarksPresentation
import BookmarksUI
import DesignSystem
import Foundation
import HTTPClient
import HTTPClientLive
import ListingsCache
import ListingsFeature
import ListingsPresentation
import ListingsUI
import SettingsFeature
import SettingsPersistence
import SettingsPresentation
import SettingsUI

@MainActor
final class AppComposition {
    let router = AppRouter()

    // MARK: - Edges

    private lazy var httpClient: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    private lazy var listingsStore: ListingsStore = CodableListingsStore(storeURL: Self.storeURL(named: "listings.json"))
    private lazy var bookmarkStore: BookmarkStore = CodableBookmarkStore(storeURL: Self.storeURL(named: "bookmarks.json"))
    private lazy var settingsStore: SettingsStore = CodableSettingsStore(storeURL: Self.storeURL(named: "settings.json"))
    private var defaultSettings: Settings = AppComposition.deviceSettings
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
    private lazy var bookmarks = LocalBookmarksLoader(store: bookmarkStore)
    private lazy var settings = LocalSettingsLoader(store: settingsStore, defaultSettings: defaultSettings)

    // MARK: - View models

    private(set) lazy var listingsViewModel = makeListingsViewModel()
    private(set) lazy var bookmarksViewModel = makeBookmarksViewModel()
    private(set) lazy var settingsViewModel = makeSettingsViewModel()

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
        bookmarkStore: BookmarkStore,
        settingsStore: SettingsStore,
        defaultSettings: Settings = AppComposition.deviceSettings,
        currentDate: @escaping @Sendable () -> Date,
        locale: Locale,
        clock: any Clock<Duration> = ContinuousClock()
    ) {
        self.init()
        self.httpClient = httpClient
        self.listingsStore = listingsStore
        self.bookmarkStore = bookmarkStore
        self.settingsStore = settingsStore
        self.defaultSettings = defaultSettings
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
        ListingsView(viewModel: listingsViewModel)
    }

    private func makeListingsViewModel() -> ListingsViewModel {
        let service = listingsService
        let bookmarks = bookmarks
        let router = router
        let currentDate = currentDate
        return ListingsViewModel(
            loadListings: { try await service.loadListings() },
            observeBookmarkedIDs: { bookmarks.observe().map { Set($0.map(\.id)) } },
            saveBookmark: { try await bookmarks.save(Bookmark(listing: $0, savedAt: currentDate())) },
            removeBookmark: { try await bookmarks.remove(id: $0) },
            notify: { router.present(.error($0)) },
            locale: locale,
            clock: clock
        )
    }
}

// MARK: - Bookmarks

extension AppComposition {
    func makeBookmarksView() -> BookmarksView {
        let router = router
        return BookmarksView(
            viewModel: bookmarksViewModel,
            onBrowseListings: { router.showListings() }
        )
    }

    private func makeBookmarksViewModel() -> BookmarksViewModel {
        let bookmarks = bookmarks
        let router = router
        return BookmarksViewModel(
            observeBookmarks: { bookmarks.observe() },
            removeBookmark: { try await bookmarks.remove(id: $0) },
            notify: { router.present(.error($0)) },
            locale: locale
        )
    }
}

// MARK: - Settings

extension AppComposition {
    static var deviceSettings: Settings {
        let code = Bundle.main.preferredLocalizations.first ?? AppLanguage.english.rawValue
        return Settings(appearance: .system, language: AppLanguage(rawValue: code) ?? .english)
    }

    func makeSettingsView() -> SettingsView {
        SettingsView(viewModel: settingsViewModel)
    }

    func locale(for language: AppLanguage) -> Locale {
        Locale(languageCode: Locale.LanguageCode(language.rawValue), languageRegion: locale.region)
    }

    func observeSettings() async {
        for await value in settings.observe() {
            let locale = locale(for: value.language)
            listingsViewModel.update(locale: locale)
            bookmarksViewModel.update(locale: locale)
            settingsViewModel.update(locale: locale)
        }
    }

    private func makeSettingsViewModel() -> SettingsViewModel {
        let settings = settings
        let router = router
        return SettingsViewModel(
            initial: defaultSettings,
            observeSettings: { settings.observe() },
            saveSettings: { try await settings.save($0) },
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
