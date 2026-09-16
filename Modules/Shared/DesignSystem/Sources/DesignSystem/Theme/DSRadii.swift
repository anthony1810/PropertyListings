import SwiftUI

public struct DSRadii: Equatable, Sendable {
    public static let designSystem = DSRadii(m: 12, l: 20)

    public let m: CGFloat
    public let l: CGFloat

    public init(m: CGFloat, l: CGFloat) {
        self.m = m
        self.l = l
    }
}
