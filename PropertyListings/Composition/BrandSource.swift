import Foundation

struct BrandSource: Equatable, Sendable {
    let documentURL: URL?
    let fallback: BrandConfiguration
}
