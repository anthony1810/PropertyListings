import SwiftUI
import Synchronization
import UIKit

public enum DSTokens {
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
}
