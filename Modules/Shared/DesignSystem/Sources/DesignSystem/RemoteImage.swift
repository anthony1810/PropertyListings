import Kingfisher
import SwiftUI

public struct RemoteImage: View {
    @Environment(\.displayScale) private var displayScale
    private let url: URL?
    private let targetSize: CGSize

    public init(url: URL?, targetSize: CGSize) {
        self.url = url
        self.targetSize = targetSize
    }

    public var body: some View {
        KFImage(url)
            .setProcessor(DownsamplingImageProcessor(size: targetSize))
            .scaleFactor(displayScale)
            .cacheOriginalImage()
            .placeholder { ImagePlaceholder(state: .loading) }
            .onFailureView { ImagePlaceholder(state: .failed) }
            .fade(duration: 0.2)
            .cancelOnDisappear(true)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

struct ImagePlaceholder: View {
    @Environment(\.theme) private var theme
    enum State { case loading, failed }
    let state: State

    var body: some View {
        ZStack {
            theme.colors.surfaceElevated
            Image(systemName: state == .failed ? "photo.badge.exclamationmark" : "photo")
                .font(.title2)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }
}

#Preview("RemoteImage placeholders") {
    VStack(spacing: DSSpacing.m) {
        RemoteImage(url: nil, targetSize: CGSize(width: 400, height: 260))
            .frame(height: 180)
            .clipShape(
                RoundedRectangle(cornerRadius: DSTheme.designSystem.radii.l, style: .continuous)
            )
        ImagePlaceholder(state: .failed)
            .frame(height: 180)
            .clipShape(
                RoundedRectangle(cornerRadius: DSTheme.designSystem.radii.l, style: .continuous)
            )
    }
    .padding()
}
