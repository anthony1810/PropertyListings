import SwiftUI

public struct LikeButton: View {
    @Environment(\.theme) private var theme
    private let isOn: Bool
    private let action: () -> Void

    public init(isOn: Bool, action: @escaping () -> Void) {
        self.isOn = isOn
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "heart.fill" : "heart")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(isOn ? theme.colors.like : theme.colors.onImage)
                .padding(10)
                .background(.ultraThinMaterial, in: Circle())
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(DesignSystemStrings.likeLabel)
        .accessibilityValue(
            isOn ? DesignSystemStrings.likeValueOn : DesignSystemStrings.likeValueOff
        )
        .accessibilityAddTraits(isOn ? .isSelected : [])
        .sensoryFeedback(.impact(weight: .light), trigger: isOn)
    }
}

#Preview("LikeButton") {
    HStack(spacing: DSSpacing.l) {
        LikeButton(isOn: false, action: {})
        LikeButton(isOn: true, action: {})
    }
    .padding(DSSpacing.xl)
    .background(Color.gray)
}
