import Testing
@testable import PropertyListings

@MainActor
@Suite struct AppRouterTests {
    @Test func init_selectsListingsWithNoAlert() {
        let sut = AppRouter()

        #expect(sut.selectedTab == .listings)
        #expect(sut.alert == nil)
    }

    @Test func present_setsTheAlertWithTheMessage() {
        let sut = AppRouter()

        sut.present(.error("A message"))

        #expect(sut.alert == .error("A message"))
        #expect(sut.alert?.message == "A message")
    }

    @Test func showListings_selectsTheListingsTab() {
        let sut = AppRouter()
        sut.selectedTab = .saved

        sut.showListings()

        #expect(sut.selectedTab == .listings)
    }

    @Test func dismissAlert_clearsTheAlert() {
        let sut = AppRouter()
        sut.present(.error("A message"))

        sut.dismissAlert()

        #expect(sut.alert == nil)
    }
}
