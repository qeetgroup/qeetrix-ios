import SwiftUI

/// The Button family's busy indicator: a faint track and a turning arc in the label colour, so it
/// takes every variant's foreground. Drawn on the web's 16-unit grid (track r 6.25, stroke 1.5 at 25%
/// opacity, a quarter arc with round caps) and scaled to the button's icon size.
///
/// Decorative: the button reports that it is busy, so the indicator is hidden from VoiceOver, as the
/// web hides it from the accessibility tree rather than nest a status region in the button's name.
///
/// It scales with Dynamic Type exactly as the icon it replaces does — the same scaled metric — so a busy
/// button keeps its size.
struct QeetrixButtonBusyIndicator: View {
    @ScaledMetric private var side: CGFloat

    init(size: QeetrixIconSize) {
        _side = ScaledMetric(wrappedValue: size.points, relativeTo: .body)
    }

    var body: some View {
        let scale = side / 16
        ZStack {
            Circle()
                .inset(by: (8 - 6.25) * scale)
                .stroke(lineWidth: 1.5 * scale)
                .opacity(0.25)
            QeetrixBusyArc()
                .stroke(style: StrokeStyle(lineWidth: 1.5 * scale, lineCap: .round))
        }
        .frame(width: side, height: side)
        .qeetrixSpinning()
        .accessibilityHidden(true)
    }
}

/// `M8 1.75 a6.25 6.25 0 0 1 6.25 6.25` in a 16-unit box: the quarter from twelve to three o'clock.
private struct QeetrixBusyArc: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = rect.width / 16
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.minX + 8 * scale, y: rect.minY + 8 * scale), radius: 6.25 * scale, startAngle: .degrees(-90),
            endAngle: .degrees(0), clockwise: false)
        return path
    }
}
