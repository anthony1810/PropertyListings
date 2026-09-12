import Foundation

public struct DSBrand: Sendable {
    public let bundle: Bundle?
    public let radii: DSRadii
    public let typeface: DSTypeface?

    public init(bundle: Bundle?, radii: DSRadii, typeface: DSTypeface?) {
        self.bundle = bundle
        self.radii = radii
        self.typeface = typeface
    }
}
