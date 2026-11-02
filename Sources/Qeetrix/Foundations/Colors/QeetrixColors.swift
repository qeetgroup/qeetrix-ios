import SwiftUI

/// `QeetrixColor` is a `ShapeStyle`: use it anywhere SwiftUI takes one, and it resolves to the light or
/// dark token value for the view's colour scheme, updating live when the scheme changes.
///
/// ```swift
/// Text("Saved")
///     .foregroundStyle(QeetrixColor.textSuccess)
///     .background(QeetrixColor.surfaceRaised)
/// ```
///
/// Where each colour may appear is a design rule, not a token (design rules §4): Ember
/// (`bgBrandBold`, `borderBrand`, `textBrand`) only for the primary action, focus, the current item,
/// checked controls and links; status colours only for status; the page on `surfaceCanvas` and content
/// on `surfaceRaised`.
///
/// Increased contrast: `@qeetrix/tokens` has no contrast context yet, so `.increased` resolves to the
/// same values as `.standard` — every designed pair already meets WCAG 2.2 AA in both schemes. When the
/// resolver gains a contrast modifier, the generator fails until it is mapped here.
extension QeetrixColor: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        rgba(for: environment.colorScheme).resolved
    }

    /// The colour for a colour scheme, for APIs that take a `Color` rather than a `ShapeStyle`.
    /// Inside a view, prefer the colour itself as a style, or read `QeetrixTheme` from the environment.
    public func color(for colorScheme: ColorScheme) -> Color {
        rgba(for: colorScheme).color
    }

    func rgba(for colorScheme: ColorScheme) -> QeetrixRGBA {
        colorScheme == .dark ? QeetrixDarkTokens.color(self) : QeetrixLightTokens.color(self)
    }
}
