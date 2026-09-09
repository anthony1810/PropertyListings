import SwiftUI

public extension View {
    func shimmering(
        duration: TimeInterval = 1.2,
        darkHighlightOpacity: Double = 0.45,
        lightHighlightOpacity: Double = 0.7
    ) -> some View {
        modifier(
            Shimmer(
                duration: duration,
                darkHighlightOpacity: darkHighlightOpacity,
                lightHighlightOpacity: lightHighlightOpacity
            )
        )
    }
}

private struct Shimmer: ViewModifier {
    private static let offScreenLeading: CGFloat = -1
    private static let offScreenTrailing: CGFloat = 1
    private static let bandStart: CGFloat = 0.35
    private static let bandPeak: CGFloat = 0.5
    private static let bandEnd: CGFloat = 0.65

    let duration: TimeInterval
    let darkHighlightOpacity: Double
    let lightHighlightOpacity: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var phase = Self.offScreenLeading

    private var highlightOpacity: Double {
        colorScheme == .dark ? darkHighlightOpacity : lightHighlightOpacity
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                if !reduceMotion {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: Self.bandStart),
                            .init(color: .white.opacity(highlightOpacity), location: Self.bandPeak),
                            .init(color: .clear, location: Self.bandEnd),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .visualEffect { [phase] content, proxy in
                        content.offset(x: phase * proxy.size.width)
                    }
                    .mask { content }
                    .blendMode(colorScheme == .dark ? .plusLighter : .normal)
                    .onAppear {
                        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                            phase = Self.offScreenTrailing
                        }
                    }
                }
            }
            .clipped()
    }
}
