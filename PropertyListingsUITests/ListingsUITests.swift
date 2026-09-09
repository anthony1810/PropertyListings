import XCTest

@MainActor
final class ListingsUITests: XCTestCase {
    func test_listingsTab_showsListingsFromTheRemote() {
        let app = launch(reset: true)

        let showsFirstListing = app.staticTexts[firstListingTitle].waitForExistence(timeout: 15)

        XCTAssertTrue(showsFirstListing)
    }

    func test_listingsTab_showsTheListingsCachedByAnEarlierLaunchWhenOffline() {
        let firstLaunch = launch(reset: true)
        _ = firstLaunch.staticTexts[firstListingTitle].waitForExistence(timeout: 15)
        firstLaunch.terminate()
        let offlineLaunch = launch(reset: false, offline: true)

        let showsCachedListing = offlineLaunch.staticTexts[firstListingTitle].waitForExistence(timeout: 15)

        XCTAssertTrue(showsCachedListing)
    }

    func test_listingsTab_showsTheErrorWithRetryWhenOfflineWithNoCache() {
        let app = launch(reset: true, offline: true)

        let showsError = app.descendants(matching: .any)["listings.error"].waitForExistence(timeout: 15)
        let showsRetry = app.buttons["Retry"].exists

        XCTAssertTrue(showsError)
        XCTAssertTrue(showsRetry)
    }

    // MARK: - Helpers

    private let firstListingTitle = "Luxuriöses Einfamilienhaus mit Pool - Musterinserat"

    private func launch(reset: Bool, offline: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        if reset { app.launchArguments += ["-reset"] }
        if offline { app.launchArguments += ["-connectivity", "offline"] }
        app.launch()
        return app
    }
}
