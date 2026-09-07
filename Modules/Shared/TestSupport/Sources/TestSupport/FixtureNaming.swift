import Foundation
import Testing

public enum FixtureLoader {
    public enum Error: Swift.Error { case missing(String) }

    public static func data(_ name: String, extension ext: String, in bundle: Bundle) throws -> Data {
        guard let url = bundle.url(forResource: name, withExtension: ext, subdirectory: "Fixtures") else {
            throw Error.missing("\(name).\(ext)")
        }
        return try Data(contentsOf: url)
    }
}

public protocol FixtureNaming: RawRepresentable, CaseIterable, Sendable where RawValue == String {
    static var bundle: Bundle { get }
    static var fileExtension: String { get }
}

public extension FixtureNaming {
    static var fileExtension: String { "json" }

    var data: Data {
        get throws { try FixtureLoader.data(rawValue, extension: Self.fileExtension, in: Self.bundle) }
    }
}

public func verifyFixtureCoverage<F: FixtureNaming>(_ type: F.Type, sourceLocation: SourceLocation = #_sourceLocation) {
    let named = Set(F.allCases.map(\.rawValue))
    let files = F.bundle.urls(forResourcesWithExtension: F.fileExtension, subdirectory: "Fixtures") ?? []
    let onDisk = Set(files.map { $0.deletingPathExtension().lastPathComponent })

    #expect(onDisk.subtracting(named).isEmpty,
            "Fixtures on disk with no enum case: \(onDisk.subtracting(named).sorted())",
            sourceLocation: sourceLocation)
    #expect(named.subtracting(onDisk).isEmpty,
            "Enum cases with no fixture on disk: \(named.subtracting(onDisk).sorted())",
            sourceLocation: sourceLocation)
}
