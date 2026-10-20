import Qeetrix
import SwiftUI

/// An app that uses Qeetrix as a Qeet Group app would: through the `Qeetrix` library product and its
/// public API only — no `@testable` import, no showcase code. `Scripts/consumer-check.sh` builds and tests
/// it against a tagged copy of the package, resolved by URL and version as an app installs a release.
@main
struct ConsumerApp: App {
    /// The documented integration: the theme stored under the web ThemeProvider's key and values.
    @AppStorage("theme") private var mode: QeetrixThemeMode = .system
    private let fonts = QeetrixFontRegistry.register()

    var body: some Scene {
        WindowGroup {
            ConsumerHome(mode: $mode, fonts: fonts)
                .qeetrixThemeMode(mode)
        }
    }
}

struct ConsumerHome: View {
    @Binding var mode: QeetrixThemeMode
    let fonts: [QeetrixFontRegistry.Registration]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Theme", selection: $mode) {
                        ForEach(QeetrixThemeMode.allCases) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                } header: {
                    QeetrixSectionHeader("Appearance").accessibilityIdentifier("appearance-header")
                }
                Section {
                    NavigationLink("Brand") { BrandScreen() }
                    NavigationLink("Sign up") { SignUpScreen() }
                    NavigationLink("Decisions") { DecisionsScreen() }
                    NavigationLink("Documents") { DocumentsScreen() }
                } header: {
                    QeetrixSectionHeader("Screens")
                }
                Section {
                    ForEach(fonts, id: \.family) { font in
                        QeetrixListItem(
                            font.family.rawValue, metadata: Text(font.isAvailable ? "Available" : "Missing"), icon: .info
                        )
                        .accessibilityIdentifier("font-\(font.family.rawValue)")
                    }
                    QeetrixListItem("Tokens", metadata: Text(tokensVersion), icon: .database)
                        .accessibilityIdentifier("tokens")
                } header: {
                    QeetrixSectionHeader("Package resources")
                }
            }
            .navigationTitle("Qeetrix consumer")
            .qeetrixNavigationBar(background: .canvas)
        }
    }

    /// The `@qeetrix/ui` version the bundled tokens were generated from, read from the package's bundle.
    private var tokensVersion: String {
        (try? QeetrixProvenance.bundled().tokens.version) ?? "Unavailable"
    }
}
