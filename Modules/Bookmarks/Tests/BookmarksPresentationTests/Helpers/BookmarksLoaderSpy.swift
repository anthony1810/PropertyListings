import BookmarksFeature
import Foundation
import TestSupport

final class BookmarksLoaderSpy: Sendable {
    enum Message: Equatable {
        case observeBookmarks
        case removeBookmark(Bookmark.ID)
        case notify(String)
    }

    let removeBookmarkStub = Stub<Void>(.success(()))

    private let _receivedMessages = LockIsolated<[Message]>([])
    private let bookmarks = AsyncStream<[Bookmark]>.makeStream()

    var receivedMessages: [Message] { _receivedMessages.value }

    func emitBookmarks(_ bookmarks: [Bookmark]) {
        self.bookmarks.continuation.yield(bookmarks)
    }

    @Sendable func observeBookmarks() -> any AsyncSequence<[Bookmark], Never> {
        _receivedMessages.withValue { $0.append(.observeBookmarks) }
        return bookmarks.stream
    }

    @Sendable func removeBookmark(_ id: Bookmark.ID) async throws {
        _receivedMessages.withValue { $0.append(.removeBookmark(id)) }
        try await removeBookmarkStub.call()
    }

    @MainActor func notify(_ message: String) {
        _receivedMessages.withValue { $0.append(.notify(message)) }
    }
}
