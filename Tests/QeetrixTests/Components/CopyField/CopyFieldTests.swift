import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Copy field")
struct CopyFieldTests {
    @Test("Layouts and wrapping are CopyField's: field or row; anywhere or none")
    func names() {
        #expect(QeetrixCopyFieldLayout.allCases.map(\.rawValue) == ["field", "row"])
        #expect(QeetrixCopyFieldWrap.allCases.map(\.rawValue) == ["anywhere", "none"])
        let field = QeetrixCopyField("ACS URL", value: "https://id.qeet.in/saml/acme/acs")
        #expect(field.layout == .field && field.wrap == .anywhere && !field.isSensitive && field.description == nil)
    }

    @Test("copy-field.css: inset.md before the value, inset.xs after Copy, gap.sm between, at least size.control.lg")
    func metrics() {
        #expect(QeetrixCopyFieldMetrics.leading == QeetrixSpace.insetMd)
        #expect(QeetrixCopyFieldMetrics.trailing == QeetrixSpace.insetXs)
        #expect(QeetrixCopyFieldMetrics.gap == QeetrixSpace.gapSm)
        #expect(QeetrixCopyFieldMetrics.valuePadding == QeetrixSpace.insetXs)
        #expect(QeetrixCopyFieldMetrics.valueType == QeetrixTypeSpec(.codeSm))
        for density in QeetrixDensity.allCases {
            #expect(QeetrixCopyFieldMetrics.minimumHeight(density) == density.sizeControlLg)
        }
    }

    @Test("The box is the read-only field: no fill and the border.strong line; disabled, the disabled fill and line")
    func surface() {
        let readOnly = QeetrixCopyFieldSurface.state(isEnabled: true)
        #expect(readOnly.background == nil)
        #expect(readOnly.bottomLine == .borderStrong)
        #expect(readOnly.frame == nil)
        #expect(readOnly.foreground == .textDefault)
        let disabled = QeetrixCopyFieldSurface.state(isEnabled: false)
        #expect(disabled.background == .bgDisabled && disabled.bottomLine == .borderDisabled && disabled.foreground == .textDisabled)
    }

    @Test("The read-only line keeps 3:1 on the surfaces a field sits on, in both schemes")
    func lineContrast() {
        for theme in [QeetrixTheme.light, .dark] {
            for surface in [QeetrixColor.surfaceCanvas, .surfaceDefault, .surfaceRaised] {
                let ratio = QeetrixAccessibility.contrastRatio(theme.resolve(.borderStrong), on: theme.resolve(surface))
                #expect(ratio >= 3, "\(surface), \(theme.colorScheme): \(ratio)")
            }
        }
    }

    @Test("wrap: .none keeps one line, except at the accessibility sizes; anywhere never limits")
    func wrapping() {
        #expect(QeetrixCopyFieldValue.lineLimit(.none, dynamicTypeSize: .large) == 1)
        #expect(QeetrixCopyFieldValue.lineLimit(.none, dynamicTypeSize: .xxxLarge) == 1)
        #expect(QeetrixCopyFieldValue.lineLimit(.none, dynamicTypeSize: .accessibility1) == nil)
        #expect(QeetrixCopyFieldValue.lineLimit(.anywhere, dynamicTypeSize: .large) == nil)
    }

    @Test("Copy is named after the label")
    func copyName() {
        #expect(QeetrixCopyStrings.copy("ACS URL") == "Copy ACS URL")
    }

    @Test("The box: the value takes the room, Copy sits at the end, the two centred; mirrored in right to left")
    func boxLayout() throws {
        // A 10 pt value beside a 20 × 30 pt button, 8 pt apart, in 100 pt.
        func box(_ direction: LayoutDirection) -> some View {
            QeetrixCopyFieldBoxLayout(spacing: 8) {
                Color(red: 1, green: 0, blue: 0).frame(height: 10)
                Color(red: 0, green: 0, blue: 1).frame(width: 20, height: 30)
            }
            .frame(width: 100)
            .environment(\.layoutDirection, direction)
        }
        let red = (r: 255, g: 0, b: 0)
        let blue = (r: 0, g: 0, b: 255)
        let ltr = try #require(Rendered(box(.leftToRight)))
        #expect(ltr.width == 100 && ltr.height == 30)
        #expect(close(red, ltr.pixel(5, 15)), "The value, centred")
        #expect(ltr.pixel(5, 5).a == 0, "Above the centred value")
        #expect(close(red, ltr.pixel(70, 15)), "The value reaches the gap")
        #expect(ltr.pixel(76, 15).a == 0, "The gap")
        #expect(close(blue, ltr.pixel(90, 2)), "Copy at the end")
        let rtl = try #require(Rendered(box(.rightToLeft)))
        #expect(close(blue, rtl.pixel(10, 2)), "Copy at the end, on the left")
        #expect(close(red, rtl.pixel(95, 15)))
    }

    @Test("It renders: field and row, wrapping or not, sensitive, disabled, alone and in a description list")
    func renders() {
        let url = "https://id.qeet.in/saml/acme-traders-private-limited/assertion-consumer-service"
        for layout in QeetrixCopyFieldLayout.allCases {
            for wrap in QeetrixCopyFieldWrap.allCases {
                let field = QeetrixCopyField(
                    "ACS URL", value: url, description: Text("Paste it into your identity provider."), layout: layout, wrap: wrap)
                for direction in [LayoutDirection.leftToRight, .rightToLeft] {
                    #expect(ImageRenderer(content: field.frame(width: 390).environment(\.layoutDirection, direction)).cgImage != nil)
                }
            }
        }
        let secret = QeetrixCopyField(label: Text("Client secret"), value: "qs_test_4f9a0c", isSensitive: true)
        #expect(ImageRenderer(content: secret.frame(width: 390).disabled(true)).cgImage != nil)
        let list = QeetrixDescriptionList {
            QeetrixDescriptionItem("Name", value: "Acme Traders")
            QeetrixCopyField("Tenant ID", value: "tn_01HZX4B7Q2", layout: .row)
            QeetrixCopyField(String("Client ID"), value: "cl_7Hq2", layout: .row)
        }
        #expect(ImageRenderer(content: list.frame(width: 600)).cgImage != nil)
    }
}
