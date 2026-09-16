import SwiftUI

public struct ListingCard: View {
    @Environment(\.theme) private var theme
    public struct Model: Sendable, Hashable {
        public let imageURL: URL?
        public let title: String
        public let priceText: String
        public let addressText: String
        public let isLiked: Bool

        public init(
            imageURL: URL?,
            title: String,
            priceText: String,
            addressText: String,
            isLiked: Bool
        ) {
            self.imageURL = imageURL
            self.title = title
            self.priceText = priceText
            self.addressText = addressText
            self.isLiked = isLiked
        }
    }

    private let model: Model
    private let likeIdentifier: String
    private let onLike: () -> Void

    public init(model: Model, likeIdentifier: String, onLike: @escaping () -> Void) {
        self.model = model
        self.likeIdentifier = likeIdentifier
        self.onLike = onLike
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            image
            Text(model.title)
                .font(theme.font(for: .title))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
            Label(model.addressText, systemImage: "mappin.and.ellipse")
                .font(theme.font(for: .caption))
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(1)
        }
    }

    private var image: some View {
        RemoteImage(url: model.imageURL, targetSize: CGSize(width: 400, height: 260))
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: theme.radii.l, style: .continuous))
            .overlay(alignment: .bottomLeading) {
                Text(model.priceText)
                    .font(theme.font(for: .price))
                    .padding(.horizontal, DSSpacing.s)
                    .padding(.vertical, DSSpacing.xs)
                    .background(.thinMaterial, in: Capsule())
                    .padding(DSSpacing.s)
            }
            .overlay(alignment: .topTrailing) {
                LikeButton(isOn: model.isLiked, action: onLike)
                    .padding(DSSpacing.s)
                    .accessibilityIdentifier(likeIdentifier)
            }
    }
}

#Preview("ListingCard") {
    ScrollView {
        VStack(spacing: DSSpacing.m) {
            ListingCard(
                model: .init(
                    imageURL: nil,
                    title: "Luxuriöses Einfamilienhaus mit Pool",
                    priceText: "CHF 9'999'999",
                    addressText: "Musterstrasse 999, 2406 La Brévine",
                    isLiked: false
                ),
                likeIdentifier: "preview.like.1",
                onLike: {}
            )
            ListingCard(
                model: .init(
                    imageURL: nil,
                    title: "Test listing",
                    priceText: "Price on request",
                    addressText: "La Brévine",
                    isLiked: true
                ),
                likeIdentifier: "preview.like.2",
                onLike: {}
            )
        }
        .padding(DSSpacing.m)
    }
    .background(DSTheme.designSystem.colors.surface)
}
