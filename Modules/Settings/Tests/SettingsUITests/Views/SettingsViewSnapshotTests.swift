#if canImport(UIKit)
import Foundation
import SettingsFeature
import SettingsPresentation
import SettingsTestSupport
import SnapshotTesting
import SwiftUI
import Testing
import TestSupport
@testable import SettingsUI

@MainActor
@Suite struct SettingsViewSnapshotTests {
    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func settings_matchesTheReference(style: UIUserInterfaceStyle) async {
        let view = await makeView(settings: makeSettings(appearance: .system, language: .german))

        assert(view, style: style, testName: "settings")
    }

    @Test func settings_followsTheEnvironmentLocale() async {
        let view = await makeView(settings: makeSettings(appearance: .dark, language: .french))
            .environment(\.locale, Locale(identifier: "fr_CH"))

        assert(view, style: .dark, testName: "settingsFrench")
    }

    // MARK: - Helpers

    private func makeView(settings: Settings) async -> some View {
        let viewModel = SettingsViewModel(
            initial: settings,
            observeSettings: { AsyncStream { $0.yield(settings); $0.finish() } },
            saveSettings: { _ in },
            notify: { _ in },
            locale: Locale(identifier: "de_CH")
        )
        await viewModel.observe()
        return NavigationStack { SettingsView(viewModel: viewModel) }
            .transaction { $0.animation = nil }
    }

    private func assert(_ view: some View, style: UIUserInterfaceStyle, testName: String) {
        assertSnapshot(
            of: view,
            as: .image(precision: 0.95, perceptualPrecision: 0.97, layout: .device(config: .iPhone17(style))),
            named: style.snapshotName,
            record: SnapshotHost.isRecording ? .all : nil,
            testName: testName
        )
    }
}
#endif
