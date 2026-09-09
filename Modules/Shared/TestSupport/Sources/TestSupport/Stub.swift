public final class Stub<Output: Sendable>: Sendable {
    private let result = LockIsolated<Result<Output, Error>?>(nil)
    private let gate = LockIsolated<Gate?>(nil)

    public init(_ initial: Result<Output, Error>? = nil) {
        result.setValue(initial)
    }

    public func complete(with newResult: Result<Output, Error>) {
        result.setValue(newResult)
    }

    public func holdNext() -> Gate {
        let next = Gate()
        gate.setValue(next)
        return next
    }

    public func call() async throws -> Output {
        await gate.value?.wait()
        gate.setValue(nil)
        return try result.value.evaluate()
    }
}
