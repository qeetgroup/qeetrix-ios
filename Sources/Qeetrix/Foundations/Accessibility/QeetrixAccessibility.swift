import SwiftUI

/// Accessibility requirements Qeetrix applies on iOS that are platform rules rather than tokens.
public enum QeetrixAccessibility {
    /// The minimum size of a tappable area, 44 × 44 pt (Apple Human Interface Guidelines). Not a
    /// Qeetrix token: the web's control heights (`QeetrixDensity`, 28–36 pt) are pointer-sized, so a
    /// control drawn at those heights must still give its hit area this size.
    public static let minimumTouchTarget: CGFloat = 44

    /// The WCAG 2.x contrast ratio of a foreground over a background, from 1 to 21. A translucent
    /// foreground is composited over the background first (in gamma-encoded sRGB, as browsers and
    /// qeetrix-ui's contrast gate do); the background is treated as opaque.
    public static func contrastRatio(_ foreground: Color.Resolved, on background: Color.Resolved) -> Double {
        let alpha = Double(foreground.opacity)
        func channel(_ f: Float, _ b: Float) -> Double {
            Double(f) * alpha + Double(b) * (1 - alpha)
        }
        let composited = (
            channel(foreground.red, background.red), channel(foreground.green, background.green), channel(foreground.blue, background.blue)
        )
        let base = (Double(background.red), Double(background.green), Double(background.blue))
        let l1 = luminance(composited)
        let l2 = luminance(base)
        return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)
    }

    static func luminance(_ rgb: (Double, Double, Double)) -> Double {
        func linear(_ value: Double) -> Double {
            let c = min(max(value, 0), 1)
            return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(rgb.0) + 0.7152 * linear(rgb.1) + 0.0722 * linear(rgb.2)
    }
}

extension View {
    /// Gives this view at least a 44 × 44 pt tappable area without changing how it is drawn.
    public func qeetrixMinimumTouchTarget() -> some View {
        frame(minWidth: QeetrixAccessibility.minimumTouchTarget, minHeight: QeetrixAccessibility.minimumTouchTarget)
            .contentShape(Rectangle())
    }
}
