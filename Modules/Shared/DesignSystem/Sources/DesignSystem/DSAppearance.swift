import SwiftUI
import UIKit

public enum DSAppearance {
    @MainActor
    public static func configure() {
        let bar = UINavigationBar.appearance()
        bar.largeTitleTextAttributes = attributes(for: .largeTitle)
        bar.titleTextAttributes = attributes(for: .title)

        let segments = UISegmentedControl.appearance()
        segments.setTitleTextAttributes(
            attributes(for: .caption, weight: .semibold),
            for: .selected
        )
        segments.setTitleTextAttributes(attributes(for: .caption), for: .normal)
    }

    private static func attributes(
        for role: DSFont.Role,
        weight: Font.Weight? = nil
    ) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        if let textPrimary = DSTokens.uiColor("textPrimary") {
            attributes[.foregroundColor] = textPrimary
        }
        if let typeface = DSTokens.typeface,
            let font = UIFont(name: typeface.name(for: weight ?? role.weight), size: role.size)
        {
            attributes[.font] = font
        }
        return attributes
    }
}
