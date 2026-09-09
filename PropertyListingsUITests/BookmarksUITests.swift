import XCTest

@MainActor
final class BookmarksUITests: XCTestCase {
    func test_savedTab_showsTheBookmarksSavedByAnEarlierLaunchWhenOffline() {
        let firstLaunch = XCUIApplication.launch(.online, store: .empty)
        firstLaunch.listingsTab.like(.firstRow)
        XCTAssertTrue(firstLaunch.listingsTab.isShowingLiked(.firstRow), "the first row's heart is on before the relaunch")
        firstLaunch.terminate()

        let offlineLaunch = XCUIApplication.launch(.offline, store: .kept)

        XCTAssertTrue(offlineLaunch.savedTab.isShowing(.firstRow), "the first row is visible on the Saved tab while offline")
    }

    func test_savedTab_showsNothingToShowWhenOfflineWithNoBookmarks() {
        let app = XCUIApplication.launch(.offline, store: .empty)

        XCTAssertTrue(app.savedTab.isShowingEmptyState, "the empty state and its Browse listings button are visible on the Saved tab")
    }

    func test_savedTab_unbookmarkingClearsTheHeartOnListings() {
        let app = XCUIApplication.launch(.online, store: .empty)
        app.listingsTab.like(.firstRow)
        XCTAssertTrue(app.savedTab.isShowing(.firstRow), "the first row is visible on the Saved tab after the like")

        app.savedTab.unbookmark(.firstRow)

        XCTAssertTrue(app.savedTab.isShowingEmptyState, "the Saved tab shows its empty state after the unbookmark")
        XCTAssertTrue(app.listingsTab.isShowingUnliked(.firstRow), "the first row's heart is off on the Listings tab")
    }
}
