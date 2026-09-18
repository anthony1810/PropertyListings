import Foundation
import Observation
import ListingsFeature

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
    
    enum ListingsRoute: Hashable {
        case detail(Listing)
    }

    var selectedTab: Tab = .listings
    var listingsRoute: [ListingsRoute] = []
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
    
    func showListingDetail(_ listing: Listing) {
        listingsRoute.append(.detail(listing))
    }
}
