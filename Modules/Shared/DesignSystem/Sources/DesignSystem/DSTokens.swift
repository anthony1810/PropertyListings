import SwiftUI
import Synchronization
import UIKit

public enum DSTokens {
    // MARK: - Brand

    @MainActor
    public static func configure(brand: DSBrand) {
        configure(bundle: brand.bundle)
        configure(radii: brand.radii)
        configure(typeface: brand.typeface)
    }

    // MARK: - Colors

    private static let registered = Mutex<Bundle?>(nil)

    public static var bundle: Bundle? {
        registered.withLock { $0 }
    }

    public static func configure(bundle: Bundle?) {
        registered.withLock { $0 = bundle }
    }

    static var designSystemBundle: Bundle { .module }

    static func color(_ name: String) -> Color {
        if let bundle, UIColor(named: name, in: bundle, compatibleWith: nil) != nil {
            return Color(name, bundle: bundle)
        }
        return Color(name, bundle: .module)
    }

    static func uiColor(_ name: String) -> UIColor? {
        if let bundle, let brand = UIColor(named: name, in: bundle, compatibleWith: nil) {
            return brand
        }
        return UIColor(named: name, in: .module, compatibleWith: nil)
    }

    // MARK: - Radii

    private static let registeredRadii = Mutex<DSRadii?>(nil)

    public static var radii: DSRadii {
        registeredRadii.withLock { $0 } ?? .designSystem
    }

    public static func configure(radii: DSRadii?) {
        registeredRadii.withLock { $0 = radii }
    }

    // MARK: - Typeface

    private static let registeredTypeface = Mutex<DSTypeface?>(nil)

    public static var typeface: DSTypeface? {
        registeredTypeface.withLock { $0 }
    }

    public static func configure(typeface: DSTypeface?) {
        registeredTypeface.withLock { $0 = typeface }
    }
}
