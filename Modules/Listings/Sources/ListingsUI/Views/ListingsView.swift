#if canImport(UIKit)
import DesignSystem
import ListingsPresentation
import SwiftUI

public struct ListingsView: View {
    private let viewModel: ListingsViewModel

    public init(viewModel: ListingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        content
            .navigationTitle(ListingsUIStrings.title)
            .background(DSColor.surface)
            .task { await viewModel.load() }
            .task { await viewModel.observeBookmarks() }
            .refreshable { await viewModel.load() }
    }
}

// MARK: - States

private extension ListingsView {
    var content: some View {
        List(viewModel.rows) { row in
            ListingCard(
                model: ListingCard.Model(
                    imageURL: row.imageURL,
                    title: row.title,
                    priceText: row.priceText,
                    addressText: row.addressText,
                    isLiked: row.isBookmarked
                ),
                likeIdentifier: AccessibilityID.like(row.id, isOn: row.isBookmarked),
                onLike: { Task { await viewModel.toggleBookmark(id: row.id) } }
            )
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(AccessibilityID.row(row.id))
            .listRowSeparator(.hidden)
            .listRowInsets(
                EdgeInsets(
                    top: DSSpacing.s,
                    leading: DSSpacing.m,
                    bottom: DSSpacing.s,
                    trailing: DSSpacing.m
                )
            )
        }
        .listStyle(.plain)
        .accessibilityIdentifier(AccessibilityID.list)
    }
}

#if DEBUG
#Preview("Content") {
    NavigationStack { ListingsView(viewModel: .preview()) }
}
#endif
#endif
