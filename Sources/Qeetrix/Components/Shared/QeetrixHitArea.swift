import SwiftUI

/// A hit shape at least ``QeetrixAccessibility/minimumTouchTarget`` square, centred on the view, so a
/// control drawn at a web control height (24–36 pt) is still a 44 pt touch target. Unlike
/// `qeetrixMinimumTouchTarget()` it does not change layout: the web Switch does the same with a
/// pointer target on a pseudo-element, so a dense row keeps its drawn spacing.
struct QeetrixHitArea: Shape {
    func path(in rect: CGRect) -> Path {
        let minimum = QeetrixAccessibility.minimumTouchTarget
        let dx = min(0, (rect.width - minimum) / 2)
        let dy = min(0, (rect.height - minimum) / 2)
        return Path(rect.insetBy(dx: dx, dy: dy))
    }
}

extension View {
    /// Extends the tappable area to at least 44 × 44 pt without moving layout.
    func qeetrixHitArea() -> some View {
        contentShape(QeetrixHitArea())
    }
}
