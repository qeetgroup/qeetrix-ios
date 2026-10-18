import SwiftUI

/// How an app chooses between the Qeetrix light and dark themes — the same three modes as the web's
/// `ThemeProvider`, with the same raw values, so a stored preference reads the same on both
/// (`@AppStorage("theme") var mode: QeetrixThemeMode = .system` works directly).
public enum QeetrixThemeMode: String, CaseIterable, Identifiable, Sendable {
    case light
    case dark
    /// Follow the system appearance.
    case system

    public var id: Self { self }

    /// The colour scheme this mode forces, or `nil` to follow the system.
    public var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        case .system: nil
        }
    }
}

extension View {
    /// Sets the theme for this view's window or presentation — the counterpart of the web's
    /// `ThemeProvider` on `<html>`. Apply it once, near the root: the system's own chrome (status bar,
    /// sheets, alerts, keyboard) follows it, and `.system` follows the device setting live.
    ///
    /// To draw one part of a screen in a fixed theme instead, use ``SwiftUI/View/qeetrixTheme(_:)``.
    public func qeetrixThemeMode(_ mode: QeetrixThemeMode) -> some View {
        preferredColorScheme(mode.colorScheme)
            .environment(\.qeetrixThemeMode, mode)
    }
}
