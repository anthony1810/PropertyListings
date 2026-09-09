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
        tabBars.buttons["Listings"].selectIfNeeded()
        return ListingsTab(app: self)
    }

    var savedTab: SavedTab {
        tabBars.buttons["Saved"].selectIfNeeded()
        return SavedTab(app: self)
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
