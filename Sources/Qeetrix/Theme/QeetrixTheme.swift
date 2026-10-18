import SwiftUI

/// The Qeetrix theme a view is drawn in: which token set applies — the upstream `light` or `dark`
/// theme — and the contrast setting it was resolved under.
///
/// A theme is derived from the SwiftUI environment, never stored globally, so it follows the view
/// hierarchy, nested overrides and live appearance changes. Read it with
/// `@Environment(\.qeetrixTheme) private var theme`.
///
/// There is no public way to build a theme from arbitrary colours: Qeetrix has one brand across every
/// Qeet product. New themes come from upstream, through the token generator.
public struct QeetrixTheme: Hashable, Sendable {
    public let colorScheme: ColorScheme
    /// The environment's contrast setting. Qeetrix has no increased-contrast values yet, so colours
    /// resolve the same under both; see ``QeetrixColor``.
    public let contrast: ColorSchemeContrast

    public init(colorScheme: ColorScheme, contrast: ColorSchemeContrast = .standard) {
        self.colorScheme = colorScheme
        self.contrast = contrast
    }

    public static let light = QeetrixTheme(colorScheme: .light)
    public static let dark = QeetrixTheme(colorScheme: .dark)

    /// A semantic colour in this theme, as a `Color`.
    public func color(_ color: QeetrixColor) -> Color {
        color.color(for: colorScheme)
    }

    /// A semantic colour in this theme, resolved to concrete components.
    public func resolve(_ color: QeetrixColor) -> Color.Resolved {
        color.rgba(for: colorScheme).resolved
    }

    /// An elevation's shadow layers in this theme.
    public func layers(_ elevation: QeetrixElevation) -> [QeetrixShadowLayer] {
        elevation.layers(for: colorScheme)
    }
}
