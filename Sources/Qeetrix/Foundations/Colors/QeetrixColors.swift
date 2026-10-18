import SwiftUI

/// `QeetrixColor` is a `ShapeStyle`: use it anywhere SwiftUI takes one, and it resolves to the light or
/// dark token value for the view's colour scheme, updating live when the scheme changes.
///
/// ```swift
/// Text("Saved")
///     .foregroundStyle(QeetrixColor.textSuccess)
///     .background(QeetrixColor.surfaceDefault)
/// ```
///
/// Increased contrast: qeetrix-ui defines no contrast theme yet, so `.increased` resolves to the same
/// values as `.standard` — every semantic text pair already meets WCAG 2.2 AA in both themes. When
/// upstream registers a contrast theme, the generator fails until it is mapped here.
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
