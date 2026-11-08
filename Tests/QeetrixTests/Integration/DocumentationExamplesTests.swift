import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The concrete examples from the foundation articles of Sources/Qeetrix/Qeetrix.docc, copied
// verbatim. If the API changes in a way that breaks an example, this file stops compiling, and the
// article must be updated with it.

/// GettingStarted.md — "Build with foundations".
private struct AccountCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
            Text("Your account")
                .qeetrixTextStyle(.titleSm)
                .foregroundStyle(QeetrixColor.textDefault)
            HStack(spacing: QeetrixSpace.gapXs) {
                QeetrixIcon(.lock, size: .sm, shape: .sharp)
                Text("Two-step verification is on").qeetrixTextStyle(.bodyMd)
            }
            .foregroundStyle(QeetrixColor.textSubtle)
        }
        .padding(QeetrixSpace.insetLg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(QeetrixColor.surfaceRaised, in: RoundedRectangle(cornerRadius: QeetrixRadius.surface))
        .overlay {
            RoundedRectangle(cornerRadius: QeetrixRadius.surface)
                .strokeBorder(QeetrixColor.borderDefault, lineWidth: QeetrixBorderWidth.default)
        }
    }
}

/// Theming.md — "Use semantic colours".
private struct HairlineRule: View {
    @Environment(\.qeetrixTheme) private var theme

    var body: some View {
        Rectangle()
            .fill(theme.color(.borderDefault))
            .frame(height: QeetrixBorderWidth.default)
    }
}

/// Sizing.md.
private struct SettingsRow: View {
    @Environment(\.qeetrixDensity) private var density

    var body: some View {
        Text("Notifications")
            .qeetrixTextStyle(.bodyMd)
            .frame(maxWidth: .infinity, minHeight: density.sizeRow, alignment: .leading)
    }
}

/// Theming.md, Typography.md, Spacing.md, Shapes.md, Elevation.md, Motion.md, Icons.md and
/// Accessibility.md snippets.
private struct Snippets: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPresented = false
    @State private var isExpanded = false

    var body: some View {
        VStack {
            Text("Payment received")
                .foregroundStyle(QeetrixColor.textSuccess)
                .padding(QeetrixSpace.insetMd)
                .background(QeetrixColor.bgSuccessSubtle, in: RoundedRectangle(cornerRadius: QeetrixRadius.control))
            VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
                Text("Title").qeetrixTextStyle(.headingSm)
                Text("Body").qeetrixTextStyle(.bodyMd)
            }
            .padding(QeetrixSpace.insetLg)
            RoundedRectangle(cornerRadius: QeetrixRadius.surface)
                .fill(QeetrixColor.surfaceRaised)
            RoundedRectangle(cornerRadius: QeetrixRadius.control)
                .stroke(QeetrixColor.borderStrong, lineWidth: QeetrixBorderWidth.default)
            Text("Saved to your library")
                .qeetrixTextStyle(.bodyMd)
                .padding(QeetrixSpace.insetLg)
                .qeetrixShadow(.overlay, fill: .surfaceOverlay, in: RoundedRectangle(cornerRadius: QeetrixRadius.overlay))
            Text("Sign in to Qeet").qeetrixTextStyle(.displaySm)
            Text("We sent a code to your phone.").qeetrixTextStyle(.bodyMd)
            Text("Panel")
                .padding(QeetrixSpace.insetLg)
                .qeetrixShadow(.overlay, fill: .surfaceOverlay, in: RoundedRectangle(cornerRadius: QeetrixRadius.overlay))
                .qeetrixAnimation(.standard, .normal, value: isExpanded)
            QeetrixIcon(.search)
            QeetrixIcon(.bell, size: .lg, variant: .filled)
            QeetrixIcon(.x, shape: .sharp)
            QeetrixIcon(.lock, label: Text("Locked"))
            Button(action: dismiss) {
                QeetrixIcon(.x, label: Text("Close"))
            }
            .qeetrixMinimumTouchTarget()
        }
    }

    func dismiss() {
        withAnimation(QeetrixMotion.animation(.enter, .normal, reduceMotion: reduceMotion)) {
            isPresented = true
        }
    }
}

@Suite("Documentation examples")
struct DocumentationExamplesTests {
    @Test("Every concrete DocC example compiles against the public API and renders")
    @MainActor
    func examplesRender() {
        #expect(ImageRenderer(content: AccountCard().frame(width: 390)).cgImage != nil)
        #expect(ImageRenderer(content: HairlineRule().frame(width: 40)).cgImage != nil)
        #expect(ImageRenderer(content: SettingsRow().qeetrixDensity(.comfortable).frame(width: 200)).cgImage != nil)
        #expect(ImageRenderer(content: Snippets().qeetrixTheme(.dark)).cgImage != nil)
    }

    @Test("GettingStarted.md — provenance example")
    func provenance() throws {
        let provenance = try QeetrixProvenance.bundled()
        #expect(provenance.tokens.version == "0.0.15")
        #expect(provenance.components.version == "0.5.1")
    }

    @Test("Migrating.md — a switch over icon names, with the default case it now needs")
    func iconSwitch() {
        var shown: [String] = []
        func showNotifications() { shown.append("notifications") }
        func showSettings() { shown.append("settings") }
        for icon in [QeetrixIconName.bell, .settings, .inbox] {
            switch icon {
            case .bell: showNotifications()
            case .settings: showSettings()
            default: break
            }
        }
        #expect(shown == ["notifications", "settings"])
    }
}
