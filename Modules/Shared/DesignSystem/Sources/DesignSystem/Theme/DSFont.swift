import SwiftUI

public enum DSFont {
    public enum Role: Sendable {
        case largeTitle, title, body, price, caption

        public var style: Font.TextStyle {
            switch self {
            case .largeTitle: .largeTitle
            case .title: .headline
            case .body: .body
            case .price: .subheadline
            case .caption: .footnote
            }
        }

        public var weight: Font.Weight {
            switch self {
            case .largeTitle: .bold
            case .title: .semibold
            case .body: .regular
            case .price: .bold
            case .caption: .regular
            }
        }

        public var size: CGFloat {
            switch self {
            case .largeTitle: 34
            case .title: 17
            case .body: 17
            case .price: 15
            case .caption: 13
            }
        }
    }

}
