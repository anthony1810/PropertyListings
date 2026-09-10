import Foundation
import Observation

@MainActor
@Observable
final class AppRouter {
    enum Tab: Hashable {
        case listings
        case saved
        case settings
    }

    enum AlertRoute: Equatable {
        case error(String)

        var message: String {
            switch self {
            case .error(let message): message
            }
        }
    }

    var selectedTab: Tab = .listings
    var alert: AlertRoute?

    func present(_ alert: AlertRoute) {
        self.alert = alert
    }

    func showListings() {
        selectedTab = .listings
    }

    func dismissAlert() {
        alert = nil
    }
}
