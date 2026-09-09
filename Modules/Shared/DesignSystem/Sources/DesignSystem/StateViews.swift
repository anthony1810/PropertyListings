import SwiftUI

public struct ErrorStateView: View {
    private let message: String
    private let retry: () -> Void

    public init(message: String, retry: @escaping () -> Void) {
        self.message = message
        self.retry = retry
    }

    public var body: some View {
        ContentUnavailableView {
            Label {
                DesignSystemStrings.errorTitle
            } icon: {
                Image(systemName: "wifi.exclamationmark")
            }
        } description: {
            Text(message)
        } actions: {
            Button(action: retry) {
                DesignSystemStrings.errorRetry
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

public struct EmptyStateView: View {
    public struct Action {
        let title: Text
        let handler: () -> Void

        public init(title: Text, handler: @escaping () -> Void) {
            self.title = title
            self.handler = handler
        }
    }

    private let title: Text
    private let hint: Text
    private let systemImage: String
    private let action: Action?

    public init(title: Text, hint: Text, systemImage: String, action: Action? = nil) {
        self.title = title
        self.hint = hint
        self.systemImage = systemImage
        self.action = action
    }

    public var body: some View {
        ContentUnavailableView {
            Label {
                title
            } icon: {
                Image(systemName: systemImage)
            }
        } description: {
            hint
        } actions: {
            if let action {
                Button(action: action.handler) {
                    action.title
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

public struct SkeletonRow: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            RoundedRectangle(cornerRadius: DSRadius.l, style: .continuous)
                .frame(height: 220)
            RoundedRectangle(cornerRadius: DSRadius.m)
                .frame(width: 220, height: 18)
            RoundedRectangle(cornerRadius: DSRadius.m)
                .frame(width: 160, height: 14)
        }
        .foregroundStyle(DSColor.surfaceElevated)
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

#Preview("ErrorStateView") {
    ErrorStateView(
        message: "Couldn't load listings. Check your connection and try again.",
        retry: {}
    )
}

#Preview("EmptyStateView") {
    EmptyStateView(
        title: Text(verbatim: "No saved listings yet"),
        hint: Text(verbatim: "Tap the heart on a listing to keep it here."),
        systemImage: "heart"
    )
}

#Preview("SkeletonRow") {
    VStack(spacing: DSSpacing.m) {
        SkeletonRow()
        SkeletonRow()
    }
    .padding(DSSpacing.m)
}
