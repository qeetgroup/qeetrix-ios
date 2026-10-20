import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("List item")
struct ListItemTests {
    @Test("Type from the web's notification row")
    func metrics() {
        #expect(QeetrixListItemMetrics.titleType.tokens.size == 14)
        #expect(QeetrixListItemMetrics.titleType.tokens.weight == .medium)
        #expect(QeetrixListItemMetrics.descriptionType.tokens.size == 14)
        #expect(QeetrixListItemMetrics.metadataType.tokens.size == 12)
        #expect(QeetrixListItemMetrics.horizontalPadding == QeetrixSpacing.l)
    }

    @Test("Every slot combination renders, selected and not, light and dark")
    func renders() {
        for scheme in [ColorScheme.light, .dark] {
            for selected in [false, true] {
                let rows = VStack(spacing: 0) {
                    QeetrixListItem("Q3 summary", isSelected: selected)
                    QeetrixListItem(
                        "Q3 summary", description: Text("Updated today"), metadata: Text("2 MB"), icon: .fileText, isSelected: selected
                    ) {
                        QeetrixBadge("Shared", variant: .secondary)
                    }
                    QeetrixListItem(title: Text("Asha Rao"), description: Text("asha@example.com"), isSelected: selected) {
                        QeetrixBadge("Owner")
                    } leading: {
                        QeetrixAvatar(name: "Asha Rao")
                    }
                    QeetrixListItem("A title long enough to wrap onto a second line in a narrow row", icon: .folder).disabled(true)
                }
                #expect(ImageRenderer(content: rows.frame(width: 320).environment(\.colorScheme, scheme)).cgImage != nil)
            }
        }
    }

    @Test("A row is at least a touch target tall, and the density's row height when that is taller")
    func height() throws {
        let row = QeetrixListItem("Files")
        let standard = try #require(Rendered(row.frame(width: 300)))
        #expect(standard.height >= 44)
        let comfortable = try #require(Rendered(row.frame(width: 300).qeetrixDensity(.comfortable)))
        #expect(comfortable.height >= Int(QeetrixDensity.comfortable.rowHeight))
    }

    @Test("Selected: the brand tint, with a 2 pt brand edge at the leading side; unselected: no fill")
    func selection() throws {
        let light = EnvironmentValues()
        let brand = QeetrixColor.borderBrand.color(for: .light).resolve(in: light).bytes
        let tint = QeetrixColor.surfaceBrandSubtle.color(for: .light).resolve(in: light).bytes
        let selected = try #require(
            Rendered(QeetrixListItem("Files", isSelected: true).frame(width: 300).environment(\.colorScheme, .light)))
        #expect(close(brand, selected.pixel(0, selected.height / 2)))
        #expect(close(brand, selected.pixel(1, selected.height / 2)))
        #expect(close(tint, selected.pixel(4, 2)))
        #expect(close(tint, selected.pixel(290, selected.height - 2)))
        let plain = try #require(Rendered(QeetrixListItem("Files").frame(width: 300)))
        #expect(plain.pixel(4, 2).a == 0)
    }

    @Test("The icon tile is 32 pt at the default text size")
    func iconTile() throws {
        let tile = try #require(Rendered(QeetrixListItemIcon(.folder)))
        #expect(tile.width == 32)
        #expect(tile.height == 32)
    }

    @Test("Section header: a group title above a muted description")
    func sectionHeader() {
        #expect(QeetrixSectionHeaderMetrics.titleType.tokens.weight == .semibold)
        #expect(QeetrixSectionHeaderMetrics.descriptionType == QeetrixListItemMetrics.descriptionType)
        let header = QeetrixSectionHeader("Members", description: Text("People with access")) {
            QeetrixButton("Invite", variant: .link, size: .sm) {}
        }
        #expect(ImageRenderer(content: header.frame(width: 320)).cgImage != nil)
    }
}
