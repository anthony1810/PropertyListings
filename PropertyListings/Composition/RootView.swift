import DesignSystem
import SettingsFeature
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

    private var language: AppLanguage { settings.appliedSettings.language }

    var body: some View {
        TabView(selection: $router.selectedTab) {
            ForEach(composition.tabs) { tab in
                Tab(value: tab.destination) {
                    NavigationStack { screen(for: tab.destination) }
                } label: {
                    Label {
                        title(for: tab.destination)
                    } icon: {
                        icon(for: tab.icon)
                    }
                }
            }
        }
        .tint(DSColor.accent)
        .environment(\.locale, composition.locale(for: language))
        .environment(\.theme, composition.theme)
        .preferredColorScheme(settings.appliedSettings.appearance.colorScheme)
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

    @ViewBuilder
    private func screen(for destination: AppRouter.Tab) -> some View {
        switch destination {
        case .listings: composition.makeListingsView()
        case .saved: composition.makeBookmarksView()
        case .settings: composition.makeSettingsView()
        }
    }

    private func title(for destination: AppRouter.Tab) -> Text {
        switch destination {
        case .listings: AppStrings.listingsTab
        case .saved: AppStrings.savedTab
        case .settings: AppStrings.settingsTab
        }
    }

    private func icon(for icon: BrandConfiguration.Tab.Icon) -> Image {
        switch icon {
        case .symbol(let name): Image(systemName: name)
        case .image(let name): Image(name)
        }
    }
}
