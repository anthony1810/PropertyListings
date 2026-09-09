import XCTest

@MainActor
final class BookmarksUITests: XCTestCase {
    func test_savedTab_unbookmarkingClearsTheHeartOnListings() {
        let app = launch(reset: true)
        let like = app.buttons["listing.like.\(firstListingID).off"]
        XCTAssertTrue(like.waitForExistence(timeout: 15))
        like.tap()
        app.tabBars.buttons["Saved"].tap()
        let savedRow = app.descendants(matching: .any)["bookmark.row.\(firstListingID)"]
        XCTAssertTrue(savedRow.waitForExistence(timeout: 10))

        app.buttons["bookmark.like.\(firstListingID)"].tap()

        let showsEmptyState = app.descendants(matching: .any)["bookmarks.empty"].waitForExistence(timeout: 5)
        app.tabBars.buttons["Listings"].tap()
        let heartIsOff = app.buttons["listing.like.\(firstListingID).off"].waitForExistence(timeout: 5)
        XCTAssertTrue(showsEmptyState)
        XCTAssertTrue(heartIsOff)
    }

    func test_savedTab_showsTheBookmarksSavedByAnEarlierLaunchWhenOffline() {
        let firstLaunch = launch(reset: true)
        let like = firstLaunch.buttons["listing.like.\(firstListingID).off"]
        XCTAssertTrue(like.waitForExistence(timeout: 15))
        like.tap()
        XCTAssertTrue(firstLaunch.buttons["listing.like.\(firstListingID).on"].waitForExistence(timeout: 5))
        firstLaunch.terminate()
        let offlineLaunch = launch(reset: false, offline: true)

        offlineLaunch.tabBars.buttons["Saved"].tap()

        let showsSavedRow = offlineLaunch.descendants(matching: .any)["bookmark.row.\(firstListingID)"].waitForExistence(timeout: 10)
        XCTAssertTrue(showsSavedRow)
    }

    func test_savedTab_showsNothingToShowWhenOfflineWithNoBookmarks() {
        let app = launch(reset: true, offline: true)

        app.tabBars.buttons["Saved"].tap()

        let showsEmptyState = app.descendants(matching: .any)["bookmarks.empty"].waitForExistence(timeout: 10)
        let showsBrowse = app.buttons["Browse listings"].exists
        XCTAssertTrue(showsEmptyState)
        XCTAssertTrue(showsBrowse)
    }

    // MARK: - Helpers

    private let firstListingID = "104123262"

    private func launch(reset: Bool, offline: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        if reset { app.launchArguments += ["-reset"] }
        if offline { app.launchArguments += ["-connectivity", "offline"] }
        app.launch()
        return app
    }
}
