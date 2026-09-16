import SwiftUI
import UIKit

public enum DSAppearance {
    @MainActor
    public static func apply(_ theme: DSTheme) {
        let bar = UINavigationBar.appearance()
        bar.largeTitleTextAttributes = attributes(theme, for: .largeTitle)
        bar.titleTextAttributes = attributes(theme, for: .title)

        let segments = UISegmentedControl.appearance()
        segments.setTitleTextAttributes(attributes(theme, for: .caption, weight: .semibold), for: .selected)
        segments.setTitleTextAttributes(attributes(theme, for: .caption), for: .normal)
    }

    private static func attributes(
        _ theme: DSTheme,
        for role: DSFont.Role,
        weight: Font.Weight? = nil
    ) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(theme.colors.textPrimary)
        ]
        if let typeface = theme.typeface,
            let font = UIFont(name: typeface.name(for: weight ?? role.weight), size: role.size)
        {
            attributes[.font] = font
        }
        return attributes
    }
}
