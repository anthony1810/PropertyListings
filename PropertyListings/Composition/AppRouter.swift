import Foundation
import Observation

@MainActor
@Observable
final class AppRouter {
    enum Tab: Hashable {
        case listings
    }

    enum AlertRoute: Equatable {
        case error(String)

        var title: String {
            switch self {
            case .error: AppStrings.errorTitle
            }
        }

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

    func dismissAlert() {
        alert = nil
    }
}
