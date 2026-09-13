import SnapshotTesting
import SwiftUI
import Testing
import TestSupport
@testable import DesignSystem

@MainActor
@Suite struct ListingCardSnapshotTests {
    @Test func card_matchesTheReference_withTheDesignSystemTheme() {
        assert(card, testName: "designSystem")
    }

    @Test func card_matchesTheReference_withAnInjectedTheme() {
        let injected = DSTheme(colors: .designSystem, radii: DSRadii(m: 4, l: 40), typeface: nil)

        assert(card.environment(\.theme, injected), testName: "injected")
    }

    // MARK: - Helpers

    private var card: some View {
        ListingCard(
            model: ListingCard.Model(
                imageURL: nil,
                title: "Haus am See",
                priceText: "CHF 1’250’000",
                addressText: "Seestrasse 12, 8000 Zürich",
                isLiked: true
            ),
            likeIdentifier: "like",
            onLike: {}
        )
        .padding(16)
        .frame(width: 402)
    }

    private func assert(_ view: some View, testName: String) {
        assertSnapshot(
            of: view,
            as: .image(
                precision: 0.95,
                perceptualPrecision: 0.97,
                layout: .sizeThatFits,
                traits: ViewImageConfig.iPhone17.traits
            ),
            record: SnapshotHost.isRecording ? .all : nil,
            testName: testName
        )
    }
}
