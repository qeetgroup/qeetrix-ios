import Qeetrix
import SwiftUI

/// An app that uses Qeetrix as a Qeet Group app would: through the `Qeetrix` library product and its
/// public API only — no `@testable` import, no showcase code. It depends on this repository's package by
/// a local reference, so it builds against the library as it is on the branch.
@main
struct ConsumerApp: App {
    /// The documented integration: the theme stored under the web QeetrixProvider's key and values.
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
                    ConsumerSectionHeader("Appearance").accessibilityIdentifier("appearance-header")
                }
                Section {
                    NavigationLink("Brand") { BrandScreen() }
                    NavigationLink("Sign up") { SignUpScreen() }
                    NavigationLink("Decisions") { DecisionsScreen() }
                    NavigationLink("Documents") { DocumentsScreen() }
                } header: {
                    ConsumerSectionHeader("Screens")
                }
                Section {
                    ForEach(fonts, id: \.family) { font in
                        ConsumerResourceRow(font.family.rawValue, value: font.isAvailable ? "Available" : "Missing", icon: .info)
                            .accessibilityIdentifier("font-\(font.family.rawValue)")
                    }
                    ConsumerResourceRow("Tokens", value: tokensVersion, icon: .database)
                        .accessibilityIdentifier("tokens")
                } header: {
                    ConsumerSectionHeader("Package resources")
                }
            }
            .navigationTitle("Qeetrix consumer")
            .qeetrixNavigationBar(background: .canvas)
        }
    }

    /// The `@qeetrix/tokens` version the bundled tokens were generated from, read from the package's bundle.
    private var tokensVersion: String {
        (try? QeetrixProvenance.bundled().tokens.version) ?? "Unavailable"
    }
}

/// A list section's heading, built from Qeetrix text: `body.sm` semibold in the subtle text colour.
struct ConsumerSectionHeader: View {
    let title: Text

    init(_ title: LocalizedStringKey) {
        self.title = Text(title)
    }

    init(title: Text) {
        self.title = title
    }

    var body: some View {
        QeetrixText(title, size: .sm, weight: .semibold, tone: .subtle)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A row naming a package resource and its state, read by VoiceOver as one element.
struct ConsumerResourceRow: View {
    let title: String
    let value: String
    let icon: QeetrixIconName

    init(_ title: String, value: String, icon: QeetrixIconName) {
        self.title = title
        self.value = value
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: QeetrixSpace.gapMd) {
            QeetrixIcon(icon, size: .sm, shape: .sharp)
                .foregroundStyle(QeetrixColor.iconSubtle)
            QeetrixText(title, tone: .default)
            Spacer(minLength: QeetrixSpace.gapSm)
            QeetrixText(value, size: .sm, tone: .subtle)
        }
        .accessibilityElement(children: .combine)
    }
}
