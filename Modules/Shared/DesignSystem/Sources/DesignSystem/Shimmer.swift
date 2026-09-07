import SwiftUI

public extension View {
    func shimmering(
        duration: TimeInterval = 1.2,
        highlightOpacity: Double = 0.45
    ) -> some View {
        modifier(Shimmer(duration: duration, highlightOpacity: highlightOpacity))
    }
}

private struct Shimmer: ViewModifier {
    private static let offScreenLeading: CGFloat = -1
    private static let offScreenTrailing: CGFloat = 1

    let duration: TimeInterval
    let highlightOpacity: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase = Self.offScreenLeading

    func body(content: Content) -> some View {
        content
            .overlay {
                if !reduceMotion {
                    LinearGradient(
                        colors: [.clear, .white.opacity(highlightOpacity), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .blendMode(.plusLighter)
                    .visualEffect { [phase] content, proxy in
                        content.offset(x: phase * proxy.size.width)
                    }
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
