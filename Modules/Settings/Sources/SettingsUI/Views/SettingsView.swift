#if canImport(UIKit)
import DesignSystem
import SettingsFeature
import SettingsPresentation
import SwiftUI

public struct SettingsView: View {
    private let viewModel: SettingsViewModel

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            Section {
                appearancePicker
            } header: {
                header(SettingsUIStrings.appearance)
            }
            Section {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    languageRow(language)
                }
            } header: {
                header(SettingsUIStrings.language)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(DSColor.surface)
        .accessibilityIdentifier(SettingsAccessibilityID.list)
        .navigationTitle(SettingsUIStrings.title)
    }
}

// MARK: - Rows

private extension SettingsView {
    var appearancePicker: some View {
        Picker(selection: appearance) {
            ForEach(Appearance.allCases, id: \.self) { appearance in
                SettingsUIStrings.label(for: appearance).tag(appearance)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .accessibilityIdentifier(SettingsAccessibilityID.appearance)
    }

    func header(_ title: Text) -> some View {
        title
            .font(DSFont.caption)
            .foregroundStyle(DSColor.textSecondary)
            .textCase(.uppercase)
    }

    var appearance: Binding<Appearance> {
        Binding(
            get: { viewModel.settings.appearance },
            set: { chosen in Task { await viewModel.select(appearance: chosen) } }
        )
    }

    func languageRow(_ language: AppLanguage) -> some View {
        let isSelected = viewModel.settings.language == language
        return Button {
            Task { await viewModel.select(language: language) }
        } label: {
            HStack {
                Text(verbatim: language.nativeName)
                    .foregroundStyle(DSColor.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(DSColor.accent)
                }
            }
        }
        .listRowBackground(DSColor.surfaceElevated)
        .accessibilityIdentifier(SettingsAccessibilityID.language(language))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Native names

private extension AppLanguage {
    var nativeName: String {
        switch self {
        case .german: "Deutsch"
        case .french: "Français"
        case .italian: "Italiano"
        case .english: "English"
        }
    }
}
#endif
