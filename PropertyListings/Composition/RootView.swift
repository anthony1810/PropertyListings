import SettingsPresentation
import SwiftUI

struct RootView: View {
    private let composition: AppComposition
    private let settings: SettingsViewModel
    @Bindable private var router: AppRouter

    init(composition: AppComposition) {
        self.composition = composition
        settings = composition.settingsViewModel
        _router = Bindable(composition.router)
    }

    var body: some View {
        TabView(selection: $router.selectedTab) {
            Tab(value: .listings) {
                NavigationStack { composition.makeListingsView() }
            } label: {
                Label { AppStrings.listingsTab } icon: { Image(systemName: "house") }
            }
            Tab(value: .saved) {
                NavigationStack { composition.makeBookmarksView() }
            } label: {
                Label { AppStrings.savedTab } icon: { Image(systemName: "heart") }
            }
            Tab(value: .settings) {
                NavigationStack { composition.makeSettingsView() }
            } label: {
                Label { AppStrings.settingsTab } icon: { Image(systemName: "slider.horizontal.3") }
            }
        }
        .environment(\.locale, composition.locale(for: settings.settings.language))
        .preferredColorScheme(settings.settings.appearance.colorScheme)
        .alert(
            AppStrings.errorTitle,
            isPresented: Binding(
                get: { router.alert != nil },
                set: { if !$0 { router.dismissAlert() } }
            ),
            presenting: router.alert
        ) { _ in
            Button(role: .cancel, action: {}) { AppStrings.ok }
        } message: { route in
            Text(route.message)
        }
        .task { await composition.validateCache() }
        .task { await settings.observe() }
        .task { await composition.observeSettings() }
    }
}
