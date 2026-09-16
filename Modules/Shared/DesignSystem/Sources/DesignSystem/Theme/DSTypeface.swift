import SwiftUI

public struct DSTypeface: Equatable, Sendable {
    public let regular: String
    public let semibold: String
    public let bold: String

    public init(regular: String, semibold: String, bold: String) {
        self.regular = regular
        self.semibold = semibold
        self.bold = bold
    }

    func name(for weight: Font.Weight) -> String {
        switch weight {
        case .bold: bold
        case .semibold: semibold
        default: regular
        }
    }
}
