import SwiftUI

/// The background behind a Qeetrix navigation bar.
public enum QeetrixNavigationBarBackground: String, CaseIterable, Sendable {
    /// The system's: transparent at the scroll edge, its material once content scrolls under it.
    case automatic
    /// The Qeetrix canvas colour, always — for a screen whose content should not show through the bar.
    case canvas
}

extension View {
    /// Qeetrix styling for the navigation bar of this view's `NavigationStack` destination: the brand
    /// tint on the back button and toolbar buttons, and the chosen background.
    ///
    /// ```swift
    /// NavigationStack {
    ///     AccountList()
    ///         .navigationTitle("Accounts")
    ///         .toolbar {
    ///             ToolbarItem(placement: .primaryAction) {
    ///                 Button { add() } label: { Label { Text("Add account") } icon: { Image(qeetrix: .plus) } }
    ///             }
    ///         }
    ///         .qeetrixNavigationBar()
    /// }
    /// ```
    ///
    /// The bar stays the system's: back navigation, the swipe-back gesture, large and inline titles and
    /// toolbar layout are untouched. iOS draws the title in the system font and decides the bar's
    /// material and button chrome; Qeetrix sets only what the platform lets an app set — the tint and
    /// the background.
    public func qeetrixNavigationBar(background: QeetrixNavigationBarBackground = .automatic) -> some View {
        modifier(QeetrixNavigationBarModifier(background: background))
    }
}

struct QeetrixNavigationBarModifier: ViewModifier {
    let background: QeetrixNavigationBarBackground

    func body(content: Content) -> some View {
        switch background {
        case .automatic:
            content.tint(QeetrixColor.textBrand)
        case .canvas:
            content
                .tint(QeetrixColor.textBrand)
                #if os(iOS)
                    .toolbarBackground(QeetrixColor.surfaceCanvas, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                #endif
        }
    }
}
