import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Description list")
struct DescriptionListTests {
    private func render(_ view: some View, width: CGFloat) throws -> Rendered {
        try #require(Rendered(view.frame(width: width).environment(\.colorScheme, .light)))
    }

    @Test("Layouts are @qeetrix/react's; columns are 1 to 4")
    func names() {
        #expect(QeetrixDescriptionListLayout.allCases.map(\.rawValue) == ["rows", "columns"])
        #expect(QeetrixDescriptionList { EmptyView() }.columns == 2)
        #expect(QeetrixDescriptionList(columns: 0) { EmptyView() }.columns == 1)
        #expect(QeetrixDescriptionList(columns: 9) { EmptyView() }.columns == 4)
    }

    @Test("description-list.css: 8 rem terms, a 24 rem breakpoint, rem 16 pt at the default size")
    func metrics() {
        #expect(QeetrixDescriptionListMetrics.rem == 16)
        #expect(QeetrixDescriptionListMetrics.termMinimum * QeetrixDescriptionListMetrics.rem == 128)
        #expect(QeetrixDescriptionListMetrics.stackedBelow * QeetrixDescriptionListMetrics.rem == 384)
    }

    @Test("Columns: as many 8 rem columns as fit, at most `columns`, sharing the width")
    func columnCount() {
        func count(_ columns: Int, _ width: CGFloat) -> Int {
            QeetrixDescriptionColumnsLayout(columns: columns, minimum: 128).count(width: width)
        }
        #expect(count(2, 358) == 2)
        #expect(count(2, 200) == 1)
        #expect(count(3, 500) == 3)
        #expect(count(4, 500) == 3)
        #expect(count(4, 1000) == 4)
        #expect(count(1, 1000) == 1)
        #expect(count(4, 50) == 1)
    }

    @Test("A text value takes its own direction; an empty one is empty")
    func isolation() {
        #expect(QeetrixDescriptionListMetrics.isolated("priya@acme.in") == "\u{2068}priya@acme.in\u{2069}")
        #expect(QeetrixDescriptionListMetrics.isolated("") == "")
        #expect(QeetrixDescriptionItem("Phone", value: nil).isEmpty)
        #expect(QeetrixDescriptionItem("Phone", value: "").isEmpty)
        #expect(!QeetrixDescriptionItem("Phone", value: "+91 98765 43210").isEmpty)
        #expect(!QeetrixDescriptionItem("Status") { QeetrixBadge("Active") }.isEmpty)
    }

    @Test("Rows: the term beside its value from 24 rem, above it below; at least size.row, padded gap.sm")
    func rows() throws {
        let item = QeetrixDescriptionList { QeetrixDescriptionItem("Email", value: "priya@acme.in") }
        // Wide: one 20 pt line of body.md in gap.sm padding is under size.row's 40 pt.
        #expect(try render(item, width: 600).height == 40)
        #expect(try render(item.qeetrixDensity(.comfortable), width: 600).height == 48)
        // Narrow: label.sm's 16 pt, gap.xs, body.md's 20 pt, in gap.sm padding.
        #expect(abs(try render(item, width: 300).height - (8 + 16 + 4 + 20 + 8)) <= 2, "A point per text block on iOS")
        // 383 pt is under 24 rem; 384 is not.
        #expect(try render(item, width: 383).height > 50)
        #expect(try render(item, width: 384).height == 40)
    }

    @Test("Rows are ruled in border.subtle between items, never above the first")
    func rules() throws {
        let list = QeetrixDescriptionList {
            QeetrixDescriptionItem("Email", value: "priya@acme.in")
            QeetrixDescriptionItem("Phone", value: "+91 98765 43210")
        }
        let image = try render(list, width: 600)
        #expect(image.height == 40 + 1 + 40)
        #expect(close(QeetrixTheme.light.resolve(.borderSubtle).bytes, image.pixel(5, 40)))
        #expect(close(QeetrixTheme.light.resolve(.borderSubtle).bytes, image.pixel(595, 40)))
        #expect(image.pixel(300, 0).a == 0, "No rule above the first item")
        // Columns are not ruled.
        let columns = try render(
            QeetrixDescriptionList(layout: .columns, columns: 1) {
                QeetrixDescriptionItem("Email", value: "a")
                QeetrixDescriptionItem("Phone", value: "b")
            }, width: 300)
        #expect((0..<columns.height).allSatisfy { !close(QeetrixTheme.light.resolve(.borderSubtle).bytes, columns.pixel(150, $0)) })
    }

    @Test("Columns: the term above the value, gap.xs, no padding; side by side where they fit")
    func columns() throws {
        let two = QeetrixDescriptionList(layout: .columns) {
            QeetrixDescriptionItem("Email", value: "a")
            QeetrixDescriptionItem("Phone", value: "b")
            QeetrixDescriptionItem("City", value: "c")
        }
        let wide = try render(two, width: 600)
        let narrow = try render(two, width: 200)
        // Two rows of 16 + 4 + 20, gap.lg apart, against three.
        #expect(abs(wide.height - (40 + 16 + 40)) <= 4, "A point per text block on iOS")
        #expect(abs(narrow.height - (40 + 16 + 40 + 16 + 40)) <= 6, "A point per text block on iOS")
    }

    @Test("An action sits at the row's end, centred; under the value where the list is narrow")
    func action() throws {
        let item = QeetrixDescriptionList {
            QeetrixDescriptionItem("Name", value: "Acme") {
                Color.red.frame(width: 60, height: 28)
            }
        }
        let wide = try render(item, width: 600)
        // The 28 pt action in gap.sm padding: 44 pt, the action at the end.
        #expect(wide.height == 44)
        #expect(wide.pixel(570, 22).r > 200 && wide.pixel(570, 22).g < 100)
        let narrow = try render(item, width: 300)
        // Under the value, at the start.
        #expect(narrow.pixel(30, narrow.height - 8 - 14).r > 200)
        #expect(narrow.pixel(270, narrow.height - 8 - 14).a == 0)
    }

    @Test("Right to left, the term starts at the right")
    func rightToLeft() throws {
        let list = QeetrixDescriptionList {
            QeetrixDescriptionItem("Name") { Color.red.frame(width: 40, height: 20) }
        }
        let ltr = try render(list, width: 600)
        let rtl = try render(list.environment(\.layoutDirection, .rightToLeft), width: 600)
        // The value column starts after the 180 pt term column and the 12 pt gap, from the start.
        #expect(ltr.pixel(200, 20).r > 200 && ltr.pixel(400, 20).a == 0)
        #expect(rtl.pixel(399, 20).r > 200 && rtl.pixel(200, 20).a == 0)
    }

    #if os(macOS)
        @Test("VoiceOver reads each pair as one element; an empty value as \"Not set\"; an action on its own")
        func accessibility() {
            let elements = ListsAccessibilityTree.elements(
                of: QeetrixDescriptionList {
                    QeetrixDescriptionItem("Email", value: "priya@acme.in")
                    QeetrixDescriptionItem("Phone", value: nil)
                    QeetrixDescriptionItem("Device", value: nil, emptyLabel: Text("Unknown"))
                    QeetrixDescriptionItem("Display name", value: "Acme", description: Text("Shown in invitations.")) {
                        QeetrixButton("Change", variant: .ghost, size: .sm) {}
                    }
                    QeetrixDescriptionItem("Status") { QeetrixBadge("Active", tone: .success) }
                }, width: 600)
            #expect(
                elements.map(\.text) == [
                    "Email, priya@acme.in", "Phone, Not set", "Device, Unknown", "Display name, Acme, Shown in invitations.", "Change",
                    "Status, Active",
                ], "\(elements)")
            #expect(elements[4].role == "AXButton")
        }
    #endif

    @Test("Lists render in both layouts and schemes, at a large text size and right to left")
    func renders() {
        let list = QeetrixDescriptionList {
            QeetrixDescriptionItem("App", value: "Qeet Pay console")
            QeetrixDescriptionItem("Status") { QeetrixBadge("Pending", tone: .warning) }
            QeetrixDescriptionItem("Phone", value: nil)
        }
        for scheme in [ColorScheme.light, .dark] {
            #expect(ImageRenderer(content: list.frame(width: 390).environment(\.colorScheme, scheme)).cgImage != nil)
        }
        #expect(ImageRenderer(content: list.frame(width: 390).environment(\.dynamicTypeSize, .accessibility3)).cgImage != nil)
        #expect(ImageRenderer(content: list.frame(width: 390).environment(\.layoutDirection, .rightToLeft)).cgImage != nil)
        #expect(
            ImageRenderer(
                content: QeetrixDescriptionList(layout: .columns, columns: 3) { QeetrixDescriptionItem("App", value: "Pay") }.frame(
                    width: 600)
            )
            .cgImage != nil)
    }
}
