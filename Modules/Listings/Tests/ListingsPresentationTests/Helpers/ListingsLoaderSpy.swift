import Foundation
import ListingsFeature
import TestSupport

final class ListingsLoaderSpy: Sendable {
    enum Message: Equatable {
        case loadListings
        case loadMore
        case observeBookmarkedIDs
        case saveBookmark(Listing)
        case removeBookmark(Listing.ID)
        case notify(String)
    }

    let loadListingsStub = Stub<Paginated<Listing>>()
    let loadMoreStub = Stub<[Listing]>()
    let saveBookmarkStub = Stub<Void>(.success(()))
    let removeBookmarkStub = Stub<Void>(.success(()))

    private let _receivedMessages = LockIsolated<[Message]>([])
    private let _onLoadListings = LockIsolated<(@MainActor @Sendable () -> Void)?>(nil)
    private let bookmarkedIDs = AsyncStream<Set<String>>.makeStream()

    var receivedMessages: [Message] { _receivedMessages.value }

    func completeListings(with result: Result<[Listing], Error>) {
        loadListingsStub.complete(with: result.map { Paginated(items: $0) })
    }

    func completeListings(with items: [Listing], thenLoadMore nextItems: Result<[Listing], Error>) {
        loadMoreStub.complete(with: nextItems)
        loadListingsStub.complete(with: .success(Paginated(items: items) { [weak self] in
            guard let self else { throw SpyError.resultNotSet }
            _receivedMessages.withValue { $0.append(.loadMore) }
            return Paginated(items: items + (try await loadMoreStub.call()))
        }))
    }

    func onNextLoadListings(_ observe: @escaping @MainActor @Sendable () -> Void) {
        _onLoadListings.setValue(observe)
    }

    func emitBookmarkedIDs(_ ids: Set<String>) {
        bookmarkedIDs.continuation.yield(ids)
    }

    @Sendable func loadListings() async throws -> Paginated<Listing> {
        _receivedMessages.withValue { $0.append(.loadListings) }
        if let observe = _onLoadListings.value {
            _onLoadListings.setValue(nil)
            await observe()
        }
        return try await loadListingsStub.call()
    }

    @Sendable func observeBookmarkedIDs() -> any AsyncSequence<Set<String>, Never> {
        _receivedMessages.withValue { $0.append(.observeBookmarkedIDs) }
        return bookmarkedIDs.stream
    }

    @Sendable func saveBookmark(_ listing: Listing) async throws {
        _receivedMessages.withValue { $0.append(.saveBookmark(listing)) }
        try await saveBookmarkStub.call()
    }

    @Sendable func removeBookmark(_ id: Listing.ID) async throws {
        _receivedMessages.withValue { $0.append(.removeBookmark(id)) }
        try await removeBookmarkStub.call()
    }

    @MainActor func notify(_ message: String) {
        _receivedMessages.withValue { $0.append(.notify(message)) }
    }
}
