import XCTest

@MainActor
final class SettingsUITests: XCTestCase {
    func test_settingsTab_pickingFrenchRelabelsTheTabsAndSurvivesRelaunch() {
        let app = XCUIApplication.launch(.online, store: .empty)

        app.settingsTab.pick(.french)

        XCTAssertTrue(app.isShowingTab(labelled: "Annonces"), "the Listings tab reads Annonces right after picking French")
        XCTAssertTrue(app.listingsTab(labelled: "Annonces").isShowingTitle("Annonces"), "the Listings navigation title reads Annonces right after picking French")
        let relaunch = XCUIApplication.launch(.online, store: .kept)
        XCTAssertTrue(relaunch.isShowingTab(labelled: "Annonces"), "the Listings tab still reads Annonces after the relaunch")
        XCTAssertTrue(relaunch.listingsTab(labelled: "Annonces").isShowing(.firstRow), "the listings load on a relaunch with French stored")
    }
}
