import UIKit

public enum DSNavigationBar {
    @MainActor
    public static func configure() {
        let bar = UINavigationBar.appearance()
        bar.largeTitleTextAttributes = attributes(for: .largeTitle)
        bar.titleTextAttributes = attributes(for: .title)
    }

    private static func attributes(for role: DSFont.Role) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        if let textPrimary = DSTokens.uiColor("textPrimary") {
            attributes[.foregroundColor] = textPrimary
        }
        if let typeface = DSTokens.typeface, let font = UIFont(name: typeface.name(for: role.weight), size: role.size) {
            attributes[.font] = font
        }
        return attributes
    }
}
