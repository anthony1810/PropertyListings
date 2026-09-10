#if canImport(UIKit)
import DesignSystem
import ListingsPresentation
import SwiftUI

public struct ListingsView: View {
    @Environment(\.locale) private var locale

    private let viewModel: ListingsViewModel

    public init(viewModel: ListingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        content
            .navigationTitle(ListingsUIStrings.title(for: locale))
            .background(DSColor.surface)
            .task { await viewModel.loadIfNeeded() }
            .task { await viewModel.observeBookmarks() }
            .refreshable { await viewModel.load() }
    }
}

// MARK: - States

private extension ListingsView {
    @ViewBuilder
    var content: some View {
        if viewModel.isLoading && viewModel.rows.isEmpty {
            loading
        } else if viewModel.rows.isEmpty, let message = viewModel.loadFailureMessage {
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
            .accessibilityIdentifier(AccessibilityID.error)
        } else if viewModel.rows.isEmpty {
            EmptyStateView(
                title: ListingsUIStrings.emptyTitle,
                hint: ListingsUIStrings.emptyHint,
                systemImage: "house"
            )
            .accessibilityIdentifier(AccessibilityID.empty)
        } else {
            list
        }
    }

    var loading: some View {
        List(0..<Self.skeletonRowCount, id: \.self) { _ in
            SkeletonRow()
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .accessibilityIdentifier(AccessibilityID.loading)
    }

    static var skeletonRowCount: Int { 3 }

    var list: some View {
        List {
            ForEach(viewModel.rows) { row in
                listingRow(row)
            }
            if viewModel.canLoadMore {
                loadMoreFooter
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .accessibilityIdentifier(AccessibilityID.list)
    }

    func listingRow(_ row: ListingRow) -> some View {
        ListingCard(
            model: ListingCard.Model(
                imageURL: row.imageURL,
                title: row.title,
                priceText: row.priceText,
                addressText: row.addressText,
                isLiked: row.isBookmarked
            ),
            likeIdentifier: AccessibilityID.like(row.id, isOn: row.isBookmarked),
            onLike: { viewModel.toggleBookmark(id: row.id) }
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.row(row.id))
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

    var loadMoreFooter: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(DSSpacing.m)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .accessibilityIdentifier(AccessibilityID.loadMore)
            .task(id: viewModel.rows.count) { await viewModel.loadMore() }
    }
}

#if DEBUG
#Preview("Content") {
    NavigationStack { ListingsView(viewModel: .preview()) }
}

#Preview("Loading more") {
    NavigationStack { ListingsView(viewModel: .previewLoadingMore()) }
}

#Preview("Loading") {
    NavigationStack { ListingsView(viewModel: .previewLoading()) }
}

#Preview("Empty") {
    NavigationStack { ListingsView(viewModel: .preview(listings: [])) }
}

#Preview("Error") {
    NavigationStack { ListingsView(viewModel: .previewFailing()) }
}
#endif
#endif
