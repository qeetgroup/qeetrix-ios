import SwiftUI

/// A gamma-encoded colour in sRGB or Display P3, as the generator converted it from OKLCH. Internal: the
/// public API is `QeetrixColor`, which picks the light or dark value from the environment.
struct QeetrixRGBA: Hashable, Sendable {
    enum Space: Hashable, Sendable {
        case sRGB
        case displayP3
    }

    let space: Space
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(_ space: Space, _ red: Double, _ green: Double, _ blue: Double, _ alpha: Double) {
        self.space = space
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    private var swiftUISpace: Color.RGBColorSpace {
        space == .sRGB ? .sRGB : .displayP3
    }

    var color: Color {
        Color(swiftUISpace, red: red, green: green, blue: blue, opacity: alpha)
    }

    var resolved: Color.Resolved {
        Color.Resolved(colorSpace: swiftUISpace, red: Float(red), green: Float(green), blue: Float(blue), opacity: Float(alpha))
    }
}

extension QeetrixRGBA {
    /// CSS `transparent`.
    static let clear = QeetrixRGBA(.sRGB, 0, 0, 0, 0)
}
