import SwiftUI

/// The sizes of ``QeetrixSpinner``, as `@qeetrix/react`'s `SpinnerSize`.
public enum QeetrixSpinnerSize: String, CaseIterable, Sendable {
    /// 14 pt.
    case sm
    /// 16 pt, the default.
    case md
    /// 20 pt.
    case lg
    /// 24 pt.
    case xl

    /// The spinner's width and height (`size.icon.xs` … `lg`).
    public var iconSize: QeetrixIconSize {
        switch self {
        case .sm: .xs
        case .md: .sm
        case .lg: .md
        case .xl: .lg
        }
    }
}

/// The colour of ``QeetrixSpinner``, as `@qeetrix/react`'s `SpinnerTone`.
public enum QeetrixSpinnerTone: String, CaseIterable, Sendable {
    /// The surrounding foreground colour, as the web's `currentColor`.
    case neutral
    /// Ember (`color.icon.brand`).
    case brand
}

/// An indeterminate wait: a 2 pt ring with a quarter gap, turning once every 800 ms
/// (2 × `motion.duration.slower`, `motion.easing.linear`), as `@qeetrix/react`'s Spinner.
///
/// ```swift
/// QeetrixSpinner()
/// QeetrixSpinner(size: .lg, tone: .brand, label: Text("Loading invoices"))
/// ```
///
/// With Reduce Motion on it stops turning, closes the ring and pulses its opacity instead, so the
/// wait stays visible. VoiceOver reads its label — "Loading" unless you give one; name what is loading
/// when the screen has more than one spinner. `isDecorative` hides it from VoiceOver where something
/// else reports the wait; ``QeetrixButton``'s `isLoading` does that for a busy button.
public struct QeetrixSpinner: View {
    let size: QeetrixSpinnerSize
    let tone: QeetrixSpinnerTone
    let label: Text?
    let isDecorative: Bool

    public init(size: QeetrixSpinnerSize = .md, tone: QeetrixSpinnerTone = .neutral, label: Text? = nil, isDecorative: Bool = false) {
        self.size = size
        self.tone = tone
        self.label = label
        self.isDecorative = isDecorative
    }

    public var body: some View {
        let ring = QeetrixSpinnerRing(side: size.iconSize.points)
        Group {
            switch tone {
            case .neutral: ring
            case .brand: ring.foregroundStyle(QeetrixColor.iconBrand)
            }
        }
        .modifier(QeetrixSpinnerAccessibility(label: label, isDecorative: isDecorative))
    }
}

struct QeetrixSpinnerAccessibility: ViewModifier {
    let label: Text?
    let isDecorative: Bool

    func body(content: Content) -> some View {
        if isDecorative {
            content.accessibilityHidden(true)
        } else {
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(label ?? QeetrixStrings.loading)
                .accessibilityAddTraits(.updatesFrequently)
        }
    }
}

/// The ring: a 2 pt border with its inline-end quarter transparent (`border-inline-end-color:
/// transparent`), turning; under Reduce Motion a whole ring fading to 35% and back every 1.6 s.
struct QeetrixSpinnerRing: View {
    let side: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// One turn: `calc(2 * var(--qx-motion-duration-slower))`.
    static let turn = 2 * QeetrixDuration.slower.seconds
    /// The reduced-motion pulse: deliberately not a token on the web, so it stays visible.
    static let pulse = 1.6
    static let width: CGFloat = 2

    var body: some View {
        Group {
            if reduceMotion { Pulse() } else { Turn() }
        }
        .frame(width: side, height: side)
        .flipsForRightToLeftLayoutDirection(true)
    }

    /// Each mode owns its animation, started on appear, so a snapshot or a first frame is drawn at
    /// rest and switching Reduce Motion restarts the right one.
    struct Turn: View {
        @State private var isTurning = false

        var body: some View {
            // The gap spans the inline-end quarter: 45° either side of three o'clock.
            Circle().inset(by: QeetrixSpinnerRing.width / 2)
                .trim(from: 0.125, to: 0.875)
                .stroke(.foreground, lineWidth: QeetrixSpinnerRing.width)
                .rotationEffect(.degrees(isTurning ? 360 : 0))
                .animation(
                    isTurning ? .linear(duration: QeetrixSpinnerRing.turn).repeatForever(autoreverses: false) : nil, value: isTurning
                )
                .onAppear { isTurning = true }
        }
    }

    struct Pulse: View {
        @State private var isFaded = false

        var body: some View {
            Circle().inset(by: QeetrixSpinnerRing.width / 2)
                .stroke(.foreground, lineWidth: QeetrixSpinnerRing.width)
                .opacity(isFaded ? 0.35 : 1)
                .animation(
                    isFaded ? .easeInOut(duration: QeetrixSpinnerRing.pulse / 2).repeatForever(autoreverses: true) : nil, value: isFaded
                )
                .onAppear { isFaded = true }
        }
    }
}
