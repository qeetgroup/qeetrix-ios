import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The concrete examples from Sources/Qeetrix/Qeetrix.docc, copied verbatim. If the API changes in a way
// that breaks an example, this file stops compiling, and the article must be updated with it.

/// GettingStarted.md — "Build with foundations".
private struct AccountCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixSpacing.s) {
            Text("Your account")
                .qeetrixTextStyle(.heading)
                .foregroundStyle(QeetrixColor.textPrimary)
            HStack(spacing: QeetrixSpacing.xs) {
                QeetrixIcon(.lock, size: .sm, variant: .filled)
                Text("Two-step verification is on").qeetrixTextStyle(.body)
            }
            .foregroundStyle(QeetrixColor.textSecondary)
        }
        .padding(QeetrixSpacing.l)
        .qeetrixElevation(.raised, fill: .surfaceElevated, in: RoundedRectangle(cornerRadius: QeetrixCorner.surface))
    }
}

/// Theming.md — "Use semantic colours".
private struct HairlineRule: View {
    @Environment(\.qeetrixTheme) private var theme

    var body: some View {
        Rectangle()
            .fill(theme.color(.borderDefault))
            .frame(height: QeetrixStroke.hairline)
    }
}

/// Sizing.md.
private struct SettingsRow: View {
    @Environment(\.qeetrixDensity) private var density

    var body: some View {
        Text("Notifications")
            .qeetrixTextStyle(.body)
            .frame(maxWidth: .infinity, minHeight: density.rowHeight, alignment: .leading)
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
                .padding(QeetrixSpacing.m)
                .background(QeetrixColor.feedbackSuccessSubtle, in: RoundedRectangle(cornerRadius: QeetrixCorner.chip))
            VStack(alignment: .leading, spacing: QeetrixSpacing.s) {
                Text("Title").qeetrixTextStyle(.heading)
                Text("Body").qeetrixTextStyle(.body)
            }
            .padding(QeetrixSpacing.l)
            RoundedRectangle(cornerRadius: QeetrixCorner.surface)
                .fill(QeetrixColor.surfaceElevated)
            RoundedRectangle(cornerRadius: QeetrixCorner.control)
                .stroke(QeetrixColor.borderControl, lineWidth: QeetrixStroke.hairline)
            Text("Saved to your library")
                .qeetrixTextStyle(.body)
                .padding(QeetrixSpacing.l)
                .qeetrixElevation(.overlay, fill: .surfaceOverlay, in: RoundedRectangle(cornerRadius: QeetrixCorner.overlay))
            Text("Two-step sign-in").qeetrixTextStyle(.heading)
            Text("We sent a code to your phone.").qeetrixTextStyle(.body)
            Text("Panel")
                .padding(QeetrixSpacing.l)
                .qeetrixElevation(.overlay, fill: .surfaceOverlay, in: RoundedRectangle(cornerRadius: QeetrixCorner.overlay))
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
        withAnimation(QeetrixMotion.animation(.enter, .fast, reduceMotion: reduceMotion)) {
            isPresented = true
        }
    }
}

@Suite("Documentation examples")
struct DocumentationExamplesTests {
    @Test("Every concrete DocC example compiles against the public API and renders")
    @MainActor
    func examplesRender() {
        #expect(ImageRenderer(content: AccountCard()).cgImage != nil)
        #expect(ImageRenderer(content: HairlineRule().frame(width: 40)).cgImage != nil)
        #expect(ImageRenderer(content: SettingsRow().qeetrixDensity(.comfortable).frame(width: 200)).cgImage != nil)
        #expect(ImageRenderer(content: Snippets().qeetrixTheme(.dark)).cgImage != nil)
    }

    @Test("GettingStarted.md — provenance example")
    func provenance() throws {
        let provenance = try QeetrixProvenance.bundled()
        #expect(!provenance.tokens.version.isEmpty)
    }

    @Test("Migrating.md — a switch over icon names, with the default case it now needs")
    func iconSwitch() {
        var shown: [String] = []
        func showNotifications() { shown.append("notifications") }
        func showSettings() { shown.append("settings") }
        for icon in [QeetrixIconName.bell, .settings, .mail] {
            switch icon {
            case .bell: showNotifications()
            case .settings: showSettings()
            default: break
            }
        }
        #expect(shown == ["notifications", "settings"])
    }
}
