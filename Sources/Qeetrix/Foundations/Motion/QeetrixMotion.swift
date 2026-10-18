import SwiftUI

extension QeetrixEasing {
    /// This curve over a duration, as a SwiftUI animation.
    public func animation(duration: QeetrixDuration) -> Animation {
        isLinear ? .linear(duration: duration.seconds) : .timingCurve(x1, y1, x2, y2, duration: duration.seconds)
    }
}

extension QeetrixMotion {
    /// The animation for an easing and duration, honouring Reduce Motion the way the web does: with
    /// Reduce Motion on, the `motion.reduced.*` tokens replace both. A zero duration returns `nil` —
    /// the change happens without animation.
    public static func animation(_ easing: QeetrixEasing, _ duration: QeetrixDuration, reduceMotion: Bool) -> Animation? {
        let (curve, length) = reduceMotion ? (reducedEasing, reducedDuration) : (easing, duration)
        return length.seconds > 0 ? curve.animation(duration: length) : nil
    }
}

struct QeetrixAnimationModifier<Value: Equatable>: ViewModifier {
    let easing: QeetrixEasing
    let duration: QeetrixDuration
    let value: Value
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.animation(QeetrixMotion.animation(easing, duration, reduceMotion: reduceMotion), value: value)
    }
}

extension View {
    /// Animates changes to `value` with a Qeetrix easing and duration, or without animation when
    /// Reduce Motion is on.
    ///
    /// ```swift
    /// panel.qeetrixAnimation(.standard, .normal, value: isExpanded)
    /// ```
    public func qeetrixAnimation<Value: Equatable>(_ easing: QeetrixEasing, _ duration: QeetrixDuration, value: Value) -> some View {
        modifier(QeetrixAnimationModifier(easing: easing, duration: duration, value: value))
    }
}
