import SwiftUI

private struct QeetrixThemeModeKey: EnvironmentKey {
    static let defaultValue: QeetrixThemeMode = .system
}

extension EnvironmentValues {
    /// The Qeetrix theme in effect here, derived from the colour scheme and contrast.
    public var qeetrixTheme: QeetrixTheme {
        QeetrixTheme(colorScheme: colorScheme, contrast: colorSchemeContrast)
    }

    /// The mode set by `.qeetrixThemeMode(_:)` above this view, or `.system` when none was.
    public internal(set) var qeetrixThemeMode: QeetrixThemeMode {
        get { self[QeetrixThemeModeKey.self] }
        set { self[QeetrixThemeModeKey.self] = newValue }
    }
}

extension View {
    /// Draws this view hierarchy in a fixed theme, whatever the app's — the counterpart of a nested
    /// `.dark` scope on the web. For previews, specimens and side-by-side comparisons; the app's own
    /// theme is set with `.qeetrixThemeMode(_:)`.
    public func qeetrixTheme(_ theme: QeetrixTheme) -> some View {
        environment(\.colorScheme, theme.colorScheme)
    }
}
