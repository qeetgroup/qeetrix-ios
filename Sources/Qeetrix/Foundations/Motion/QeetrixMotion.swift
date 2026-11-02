import SwiftUI

extension QeetrixEasing {
    /// This curve over a duration, as a SwiftUI animation.
    public func animation(duration: QeetrixDuration) -> Animation {
        isLinear ? .linear(duration: duration.seconds) : .timingCurve(x1, y1, x2, y2, duration: duration.seconds)
    }
}

extension QeetrixSpring {
    /// The spring as a SwiftUI animation: mass 1, this stiffness, and the damping that gives this
    /// damping ratio (ζ = c / 2√(k·m)).
    public var animation: Animation {
        .interpolatingSpring(mass: 1, stiffness: stiffness, damping: 2 * dampingRatio * stiffness.squareRoot())
    }
}

extension QeetrixMotion {
    /// The animation for an easing and duration, honouring Reduce Motion the way the web does: with
    /// Reduce Motion on, every duration becomes ``reducedDuration`` (tokens.css's
    /// `prefers-reduced-motion` block, 0 ms). A zero duration returns `nil` — the change happens
    /// without animation.
    public static func animation(_ easing: QeetrixEasing, _ duration: QeetrixDuration, reduceMotion: Bool) -> Animation? {
        let length = reduceMotion ? reducedDuration : duration
        return length.seconds > 0 ? easing.animation(duration: length) : nil
    }

    /// A spring's animation, or `nil` under Reduce Motion: the change happens without motion.
    public static func animation(_ spring: QeetrixSpring, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : spring.animation
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
    ///
    /// Design rules §18: hover, press and colour changes take `fast` with `standard`; a switch thumb
    /// or tab bar `normal` with `standard`; anything entering `enter`, anything leaving `exit`, one step
    /// faster than it came in.
    public func qeetrixAnimation<Value: Equatable>(_ easing: QeetrixEasing, _ duration: QeetrixDuration, value: Value) -> some View {
        modifier(QeetrixAnimationModifier(easing: easing, duration: duration, value: value))
    }
}
