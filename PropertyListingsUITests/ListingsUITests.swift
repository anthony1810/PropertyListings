import XCTest

@MainActor
final class ListingsUITests: XCTestCase {
    func test_listingsTab_showsListingsFromTheRemote() {
        let app = XCUIApplication.launch(.online, store: .empty)

        XCTAssertTrue(app.listingsTab.isShowing(.firstRow), "the first row is visible on the Listings tab")
    }

    func test_listingsTab_showsTheListingsCachedByAnEarlierLaunchWhenOffline() {
        let firstLaunch = XCUIApplication.launch(.online, store: .empty)
        XCTAssertTrue(firstLaunch.listingsTab.isShowing(.firstRow), "the first row is visible before the relaunch")
        firstLaunch.terminate()

        let offlineLaunch = XCUIApplication.launch(.offline, store: .kept)

        XCTAssertTrue(offlineLaunch.listingsTab.isShowing(.firstRow), "the first row is visible on the Listings tab while offline")
    }

    func test_listingsTab_showsTheErrorWithRetryWhenOfflineWithNoCache() {
        let app = XCUIApplication.launch(.offline, store: .empty)

        XCTAssertTrue(app.listingsTab.isShowingErrorWithRetry, "the error state and its Retry button are visible on the Listings tab")
    }

    func test_listingsTab_keepsALikeAcrossRelaunch() {
        let firstLaunch = XCUIApplication.launch(.online, store: .empty)
        firstLaunch.listingsTab.like(.firstRow)
        XCTAssertTrue(firstLaunch.listingsTab.isShowingLiked(.firstRow), "the first row's heart is on before the relaunch")
        firstLaunch.terminate()

        let secondLaunch = XCUIApplication.launch(.online, store: .kept)

        XCTAssertTrue(secondLaunch.listingsTab.isShowingLiked(.firstRow), "the first row's heart is on after the relaunch")
    }
}
