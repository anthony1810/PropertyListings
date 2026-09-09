#if canImport(UIKit)
import BookmarksPresentation
import DesignSystem
import SwiftUI

public struct BookmarksView: View {
    private let viewModel: BookmarksViewModel
    private let onBrowseListings: () -> Void

    public init(viewModel: BookmarksViewModel, onBrowseListings: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onBrowseListings = onBrowseListings
    }

    public var body: some View {
        content
            .navigationTitle(BookmarksUIStrings.title)
            .background(DSColor.surface)
            .task { await viewModel.observe() }
    }
}

// MARK: - States

private extension BookmarksView {
    @ViewBuilder
    var content: some View {
        if viewModel.rows.isEmpty {
            EmptyStateView(
                title: BookmarksUIStrings.emptyTitle,
                hint: BookmarksUIStrings.emptyHint,
                systemImage: "heart",
                action: EmptyStateView.Action(title: BookmarksUIStrings.browse, handler: onBrowseListings)
            )
            .accessibilityIdentifier(BookmarksAccessibilityID.empty)
        } else {
            list
        }
    }

    var list: some View {
        List {
            ForEach(viewModel.rows) { row in
                bookmarkRow(row)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .accessibilityIdentifier(BookmarksAccessibilityID.list)
    }

    func bookmarkRow(_ row: BookmarkRow) -> some View {
        ListingCard(
            model: ListingCard.Model(
                imageURL: row.imageURL,
                title: row.title,
                priceText: row.priceText,
                addressText: row.addressText,
                isLiked: true
            ),
            likeIdentifier: BookmarksAccessibilityID.like(row.id),
            onLike: { Task { await viewModel.remove(id: row.id) } }
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(BookmarksAccessibilityID.row(row.id))
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task { await viewModel.remove(id: row.id) }
            } label: {
                Label(BookmarksUIStrings.remove, systemImage: "trash")
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(
            EdgeInsets(
                top: DSSpacing.m,
                leading: DSSpacing.m,
                bottom: DSSpacing.m,
                trailing: DSSpacing.m
            )
        )
    }
}

#if DEBUG
#Preview("Content") {
    NavigationStack { BookmarksView(viewModel: .preview(), onBrowseListings: {}) }
}

#Preview("Empty") {
    NavigationStack { BookmarksView(viewModel: .preview(bookmarks: []), onBrowseListings: {}) }
}
#endif
#endif
