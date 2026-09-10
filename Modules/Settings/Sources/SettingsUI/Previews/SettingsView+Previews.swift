#if DEBUG && canImport(UIKit)
import Foundation
import SettingsFeature
import SettingsPresentation
import SwiftUI

extension SettingsViewModel {
    static func preview(settings: Settings = Settings(appearance: .system, language: .german)) -> SettingsViewModel {
        SettingsViewModel(
            initial: settings,
            observeSettings: { AsyncStream { $0.yield(settings) } },
            saveSettings: { _ in },
            notify: { _ in },
            locale: Locale(identifier: "de_CH"),
            clock: ContinuousClock()
        )
    }
}

#Preview("Settings") {
    NavigationStack { SettingsView(viewModel: .preview()) }
}

#Preview("Settings, dark, French") {
    NavigationStack { SettingsView(viewModel: .preview(settings: Settings(appearance: .dark, language: .french))) }
        .preferredColorScheme(.dark)
        .environment(\.locale, Locale(identifier: "fr_CH"))
}
#endif
