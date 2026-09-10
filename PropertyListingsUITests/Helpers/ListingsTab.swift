import XCTest

@MainActor
struct ListingsTab {
    let app: XCUIApplication

    func isShowing(_ listing: LiveListing) -> Bool {
        app.staticTexts[listing.title].appears()
    }

    func isShowingLiked(_ listing: LiveListing) -> Bool {
        app.buttons["listing.like.\(listing.id).on"].appears()
    }

    func isShowingUnliked(_ listing: LiveListing) -> Bool {
        app.buttons["listing.like.\(listing.id).off"].appears()
    }

    func isShowingTitle(_ title: String) -> Bool {
        app.navigationBars[title].appears()
    }

    var isShowingErrorWithRetry: Bool {
        app.descendants(matching: .any)["listings.error"].appears() && app.buttons["Retry"].exists
    }

    func like(_ listing: LiveListing) {
        let heart = app.buttons["listing.like.\(listing.id).off"]
        XCTAssertTrue(heart.appears(), "expected an unliked heart on \(listing.id) to tap")
        heart.tap()
    }
}
