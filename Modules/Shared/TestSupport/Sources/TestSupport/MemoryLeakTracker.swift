import Foundation
import Testing

public final class MemoryLeakTracker: @unchecked Sendable {
    private weak var instance: AnyObject?
    private let sourceLocation: SourceLocation

    public init(instance: AnyObject, sourceLocation: SourceLocation) {
        self.instance = instance
        self.sourceLocation = sourceLocation
    }

    public func verify() {
        #expect(instance == nil, "Potential memory leak: instance was not deallocated.", sourceLocation: sourceLocation)
    }
}

public enum SpyError: Error { case resultNotSet }

public extension Optional {
    func evaluate<Success, Failure: Error>() throws -> Success where Wrapped == Result<Success, Failure> {
        switch self {
        case .none: throw SpyError.resultNotSet
        case .some(let result): return try result.get()
        }
    }
}

public func anyURL() -> URL { URL(string: "https://any-url.com")! }
public func anyNSError() -> NSError { NSError(domain: "any", code: 0) }
public func anyHTTPURLResponse(statusCode: Int = 200) -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}
