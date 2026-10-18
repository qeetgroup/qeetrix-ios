import Qeetrix  // deliberately not @testable: this file may only use the public API
import SwiftUI
import Testing

/// A consumer's view, written against the public API only. If a public name changes, this stops
/// compiling — the cheapest source-compatibility check there is.
private struct ConsumerView: View {
    @Environment(\.qeetrixTheme) private var theme
    @Environment(\.qeetrixDensity) private var density
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixSpacing.m) {
            Text("Welcome back").qeetrixTextStyle(.title).foregroundStyle(QeetrixColor.textPrimary)
            Text("Body copy").qeetrixTextStyle(.body).foregroundStyle(QeetrixColor.textSecondary)
            HStack(spacing: QeetrixSpacing.s) {
                QeetrixIcon(.lock, size: .sm, shape: .sharp, variant: .filled, label: Text("Locked"))
                QeetrixIcon(.search)
            }
            .foregroundStyle(QeetrixColor.textBrand)
            Rectangle()
                .fill(theme.color(.borderDefault))
                .frame(height: QeetrixStroke.hairline)
                .frame(minHeight: density.controlHeight)
                .qeetrixMinimumTouchTarget()
        }
        .padding(QeetrixSpacing.l)
        .qeetrixElevation(.raised, fill: .surfaceElevated, in: RoundedRectangle(cornerRadius: QeetrixCorner.surface))
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
        let renderer = ImageRenderer(content: ConsumerView().qeetrixTheme(.dark))
        #expect(renderer.cgImage != nil)
    }

    @Test("Public token types are usable without @testable")
    func tokenTypes() throws {
        #expect(QeetrixColor.allCases.count > 0)
        #expect(QeetrixElevation.allCases.contains(.modal))
        #expect(QeetrixTextRole.body.tokens.family == .sans)
        #expect(QeetrixFontRegistry.isAvailable(.sans))
        #expect(QeetrixAccessibility.minimumTouchTarget == 44)
        #expect(try QeetrixProvenance.bundled().tokens.package == "@qeetrix/ui")
    }
}
