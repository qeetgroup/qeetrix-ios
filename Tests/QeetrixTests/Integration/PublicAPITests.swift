import Qeetrix  // deliberately not @testable: this file may only use the public API
import SwiftUI
import Testing

/// A consumer's view, written against the public API only. If a public name changes, this stops
/// compiling — the cheapest source-compatibility check there is.
private struct ConsumerView: View {
    @Environment(\.qeetrixTheme) private var theme
    @Environment(\.qeetrixDensity) private var density
    @State private var expanded = false
    @State private var email = ""
    @State private var renew = true

    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
            QeetrixHeading("Welcome back", level: 1)
            QeetrixText("Body copy", tone: .subtle)
            Text("A role directly").qeetrixTextStyle(.labelMd).foregroundStyle(QeetrixColor.textDefault)
            HStack(spacing: QeetrixSpace.gapSm) {
                QeetrixIcon(.lock, size: .sm, shape: .sharp, variant: .filled, label: Text("Locked"))
                QeetrixIcon(.search)
                QeetrixBadge("Paid", tone: .success)
            }
            .foregroundStyle(QeetrixColor.iconBrand)
            QeetrixTextField("Work email", text: $email, prompt: Text("e.g. priya@acme.in"))
            QeetrixSwitch("Auto-renew", isOn: $renew)
            HStack {
                QeetrixButton("Save", size: .lg) {}
                QeetrixButton("Cancel", variant: .ghost, size: .lg) {}
                QeetrixIconButton(.x, label: "Close", tone: .neutral) {}
            }
            Rectangle()
                .fill(theme.color(.borderDefault))
                .frame(height: QeetrixBorderWidth.default)
                .frame(minHeight: density.controlHeight(.md))
                .qeetrixMinimumTouchTarget()
        }
        .padding(QeetrixSpace.insetLg)
        .qeetrixShadow(.overlay, fill: .surfaceOverlay, in: RoundedRectangle(cornerRadius: QeetrixRadius.overlay))
        .qeetrixAnimation(.standard, .normal, value: expanded)
        .qeetrixDensity(.comfortable)
        .qeetrixThemeMode(.system)
    }
}

@Suite("Public API")
struct PublicAPITests {
    @Test("A consumer view built only from the public API renders")
    @MainActor
    func consumerView() {
        let renderer = ImageRenderer(content: ConsumerView().frame(width: 390).qeetrixTheme(.dark))
        #expect(renderer.cgImage != nil)
    }

    @Test("Public token types are usable without @testable")
    func tokenTypes() throws {
        #expect(QeetrixColor.allCases.count == 110)
        #expect(QeetrixShadow.allCases.contains(.modal))
        #expect(QeetrixTextRole.bodyMd.tokens.family == .sans)
        #expect(QeetrixTextRole.allCases.count == 18)
        #expect(QeetrixDensity.default.controlHeight(.lg) == 40)
        #expect(QeetrixFontRegistry.isAvailable(.sans))
        #expect(QeetrixAccessibility.minimumTouchTarget == 44)
        let provenance = try QeetrixProvenance.bundled()
        #expect(provenance.tokens.package == "@qeetrix/tokens")
        #expect(provenance.components.package == "@qeetrix/react")
        #expect(provenance.icons.package == "@qeetrix/icons")
    }
}
