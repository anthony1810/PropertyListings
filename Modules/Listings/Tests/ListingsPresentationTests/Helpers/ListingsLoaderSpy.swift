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

    private let _receivedMessages = LockIsolated<[Message]>([])
    private let _listingsResult = LockIsolated<Result<Paginated<Listing>, Error>?>(nil)
    private let _loadMoreHold = LockIsolated<AsyncStream<Void>?>(nil)
    private let _loadMoreRelease = LockIsolated<AsyncStream<Void>.Continuation?>(nil)
    private let _onLoadListings = LockIsolated<(@MainActor @Sendable () -> Void)?>(nil)
    private let _loadHold = LockIsolated<AsyncStream<Void>?>(nil)
    private let _loadRelease = LockIsolated<AsyncStream<Void>.Continuation?>(nil)
    private let bookmarkedIDs = AsyncStream<Set<String>>.makeStream()
    private let _saveResult = LockIsolated<Result<Void, Error>?>(.success(()))
    private let _removeResult = LockIsolated<Result<Void, Error>?>(.success(()))

    var receivedMessages: [Message] { _receivedMessages.value }

    func completeListings(with result: Result<[Listing], Error>) {
        _listingsResult.setValue(result.map { Paginated(items: $0) })
    }

    func completeListings(with items: [Listing], thenLoadMore nextItems: Result<[Listing], Error>) {
        _listingsResult.setValue(.success(Paginated(items: items) { [weak self] in
            guard let self else { throw SpyError.resultNotSet }
            
            _receivedMessages.withValue { $0.append(.loadMore) }
            
            if let hold = _loadMoreHold.value {
                _loadMoreHold.setValue(nil)
                for await _ in hold {}
            }
            
            return Paginated(items: items + (try nextItems.get()))
        }))
    }

    func holdNextLoadListings() {
        let (stream, continuation) = AsyncStream<Void>.makeStream()
        _loadHold.setValue(stream)
        _loadRelease.setValue(continuation)
    }

    func releaseLoadListings() {
        _loadRelease.value?.finish()
    }

    func holdNextLoadMore() {
        let (stream, continuation) = AsyncStream<Void>.makeStream()
        _loadMoreHold.setValue(stream)
        _loadMoreRelease.setValue(continuation)
    }

    func releaseLoadMore() {
        _loadMoreRelease.value?.finish()
    }

    func onNextLoadListings(_ observe: @escaping @MainActor @Sendable () -> Void) {
        _onLoadListings.setValue(observe)
    }

    @Sendable func loadListings() async throws -> Paginated<Listing> {
        _receivedMessages.withValue { $0.append(.loadListings) }
        if let observe = _onLoadListings.value {
            _onLoadListings.setValue(nil)
            await observe()
        }
        if let hold = _loadHold.value {
            _loadHold.setValue(nil)
            for await _ in hold {}
        }
        return try _listingsResult.value.evaluate()
    }

    func completeSaveBookmark(with error: Error) {
        _saveResult.setValue(.failure(error))
    }

    func completeRemoveBookmark(with error: Error) {
        _removeResult.setValue(.failure(error))
    }

    func emitBookmarkedIDs(_ ids: Set<String>) {
        bookmarkedIDs.continuation.yield(ids)
    }

    @Sendable func observeBookmarkedIDs() -> any AsyncSequence<Set<String>, Never> {
        _receivedMessages.withValue { $0.append(.observeBookmarkedIDs) }
        return bookmarkedIDs.stream
    }

    @Sendable func saveBookmark(_ listing: Listing) async throws {
        _receivedMessages.withValue { $0.append(.saveBookmark(listing)) }
        try _saveResult.value.evaluate()
    }

    @Sendable func removeBookmark(_ id: Listing.ID) async throws {
        _receivedMessages.withValue { $0.append(.removeBookmark(id)) }
        try _removeResult.value.evaluate()
    }

    @MainActor func notify(_ message: String) {
        _receivedMessages.withValue { $0.append(.notify(message)) }
    }
}
