import SwiftUI

/// `animate-spin`: one linear turn a second, forever — and, as `motion-reduce:animate-none` and the
/// web's reduced-motion rule do, no turning at all when Reduce Motion is on.
///
/// The angle is state set on appear, so a snapshot or a first frame is drawn at rest (0°, which a
/// full turn returns to).
struct QeetrixSpinning: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSpinning = false

    func body(content: Content) -> some View {
        content
            .animation(isSpinning ? .linear(duration: QeetrixWebScale.spinDuration).repeatForever(autoreverses: false) : nil) {
                $0.rotationEffect(.degrees(isSpinning ? 360 : 0))
            }
            .onAppear { isSpinning = !reduceMotion }
            .onChange(of: reduceMotion) { _, reduce in isSpinning = !reduce }
    }
}

extension View {
    func qeetrixSpinning() -> some View {
        modifier(QeetrixSpinning())
    }
}
