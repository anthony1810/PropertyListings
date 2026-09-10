import XCTest

@MainActor
extension XCUIApplication {
    enum Connectivity {
        case online
        case offline
    }

    enum Store {
        case empty
        case kept
    }

    static func launch(_ connectivity: Connectivity, store: Store) -> XCUIApplication {
        let app = XCUIApplication()
        if store == .empty {
            app.launchArguments += ["-reset"]
        }
        if connectivity == .offline {
            app.launchArguments += ["-connectivity", "offline"]
        }
        app.launch()
        return app
    }

    var listingsTab: ListingsTab {
        listingsTab(labelled: "Listings")
    }

    func listingsTab(labelled label: String) -> ListingsTab {
        tabBars.buttons[label].selectIfNeeded()
        return ListingsTab(app: self)
    }

    var savedTab: SavedTab {
        tabBars.buttons["Saved"].selectIfNeeded()
        return SavedTab(app: self)
    }

    var settingsTab: SettingsTab {
        tabBars.buttons["Settings"].selectIfNeeded()
        return SettingsTab(app: self)
    }

    func isShowingTab(labelled label: String) -> Bool {
        tabBars.buttons[label].appears()
    }
}

@MainActor
extension XCUIElement {
    static let appearanceTimeout: TimeInterval = 15

    func appears() -> Bool {
        waitForExistence(timeout: Self.appearanceTimeout)
    }

    func selectIfNeeded() {
        if !isSelected {
            tap()
        }
    }
}
