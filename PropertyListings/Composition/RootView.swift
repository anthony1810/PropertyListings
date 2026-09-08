import SwiftUI

struct RootView: View {
    private let composition: AppComposition
    @Bindable private var router: AppRouter

    init(composition: AppComposition) {
        self.composition = composition
        _router = Bindable(composition.router)
    }

    var body: some View {
        TabView(selection: $router.selectedTab) {
            Tab(AppStrings.listingsTab, systemImage: "house", value: .listings) {
                NavigationStack { composition.makeListingsView() }
            }
        }
        .alert(
            router.alert?.title ?? "",
            isPresented: Binding(
                get: { router.alert != nil },
                set: { if !$0 { router.dismissAlert() } }
            ),
            presenting: router.alert
        ) { _ in
            Button(AppStrings.ok, role: .cancel) {}
        } message: { route in
            Text(route.message)
        }
        .task { await composition.validateCache() }
    }
}
