import Qeetrix
import SwiftUI

@main
struct QeetrixShowcaseApp: App {
    /// Stored under the same key and values as the web ThemeProvider's preference. Applied in
    /// `ShowcaseRoot`, not here: a WindowGroup's content isn't rebuilt when the App's state changes.
    @AppStorage("theme") private var mode: QeetrixThemeMode = .system

    init() {
        // Register the bundled fonts at launch so a problem is logged before the first frame.
        QeetrixFontRegistry.register()
    }

    var body: some Scene {
        WindowGroup {
            ShowcaseRoot(mode: $mode)
        }
    }
}
