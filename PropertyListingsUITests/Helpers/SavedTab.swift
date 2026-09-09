import XCTest

@MainActor
struct SavedTab {
    let app: XCUIApplication

    func isShowing(_ listing: LiveListing) -> Bool {
        app.descendants(matching: .any)["bookmark.row.\(listing.id)"].appears()
    }

    var isShowingEmptyState: Bool {
        app.descendants(matching: .any)["bookmarks.empty"].appears() && app.buttons["Browse listings"].exists
    }

    func unbookmark(_ listing: LiveListing) {
        let heart = app.buttons["bookmark.like.\(listing.id)"]
        XCTAssertTrue(heart.appears(), "expected \(listing.id) on the Saved tab to tap")
        heart.tap()
    }
}
