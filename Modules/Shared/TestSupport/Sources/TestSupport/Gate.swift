public final class Gate: Sendable {
    private let stream: AsyncStream<Void>
    private let continuation: AsyncStream<Void>.Continuation

    public init() {
        (stream, continuation) = AsyncStream<Void>.makeStream()
    }

    public func wait() async {
        for await _ in stream {}
    }

    public func open() {
        continuation.finish()
    }
}
