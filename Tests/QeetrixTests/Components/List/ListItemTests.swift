import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("List item")
struct ListItemTests {
    private func kind<L, T>(_ item: QeetrixListItem<L, T>) -> String {
        switch item.control {
        case .none: "static"
        case .button: "button"
        case .link: "link"
        case .toggle: "toggle"
        }
    }

    private func select() {}

    @Test("Accessories are iOS's own: none, or the chevron")
    func accessories() {
        #expect(QeetrixListItemAccessory.allCases.map(\.rawValue) == ["none", "chevron"])
        #expect(QeetrixListItemEnd(.none) == .none)
        #expect(QeetrixListItemEnd(.chevron) == .chevron)
    }

    @Test("The initialiser decides what the row is: content, a button, a link or a switch")
    func controls() {
        #expect(kind(QeetrixListItem("Storage")) == "static")
        #expect(kind(QeetrixListItem("Storage") { QeetrixListItemIcon(.database) }) == "static")
        #expect(kind(QeetrixListItem("Select") { select() }) == "button")
        #expect(kind(QeetrixListItem("Select", action: {})) == "button")
        #expect(
            kind(
                QeetrixListItem("Sign out", role: .destructive) {
                    select()
                } leading: {
                    QeetrixListItemIcon(.x)
                }) == "button")
        #expect(kind(QeetrixListItem("Account", value: 1)) == "link")
        #expect(kind(QeetrixListItem("Face ID", isOn: .constant(true))) == "toggle")
        let name = "Priya Sharma"
        #expect(kind(QeetrixListItem(name, value: "priya")) == "link")
        #expect(kind(QeetrixListItem(title: Text(name), isOn: .constant(false))) == "toggle")
        // A link row always shows the chevron.
        #expect(QeetrixListItem("Account", value: 1).accessory == .chevron)
    }

    @Test("Rows are the density's size.row and never under 44 pt; the page gutter at the sides")
    func metrics() {
        #expect(QeetrixDensity.allCases.map(QeetrixListItemMetrics.minimumHeight) == [44, 48, 44])
        #expect(QeetrixListItemMetrics.inlinePadding == QeetrixSpace.insetLg)
        #expect(QeetrixListItemMetrics.blockPadding == QeetrixSpace.gapXs)
        #expect(QeetrixListItemMetrics.iconTile == QeetrixAvatarSize.md.points)
    }

    @Test("A row renders at least 44 pt, and 48 pt in the comfortable density")
    func heights() throws {
        func height(_ view: some View) throws -> Int {
            try #require(Rendered(view.frame(width: 390))).height
        }
        #expect(try height(QeetrixListItem("Storage")) == 44)
        #expect(try height(QeetrixListItem("Storage", action: {})) == 44)
        #expect(try height(QeetrixListItem("Storage").qeetrixDensity(.compact)) == 44)
        #expect(try height(QeetrixListItem("Storage").qeetrixDensity(.comfortable)) == 48)
        // label.md's 20 pt line and body.sm's 16 pt, 4 pt above and below.
        #expect(
            abs(try height(QeetrixListItem("Storage", description: Text("Used this month"))) - 44) <= 2, "A point per text block on iOS")
    }

    @Test(".qx-table-row: Ember tint when selected, neutral tints when pressed or hovered")
    func backgrounds() {
        func fill(selected: Bool = false, pressed: Bool = false, hovered: Bool = false, enabled: Bool = true) -> QeetrixColor? {
            QeetrixListItemMetrics.background(isSelected: selected, isPressed: pressed, isHovered: hovered, isEnabled: enabled)
        }
        #expect(fill() == nil)
        #expect(fill(hovered: true) == .bgNeutralSubtle)
        #expect(fill(pressed: true) == .bgNeutralSubtleHover)
        #expect(fill(selected: true) == .bgSelected)
        #expect(fill(selected: true, hovered: true) == .bgSelected)
        #expect(fill(selected: true, pressed: true) == .bgSelectedHover)
        // A disabled row doesn't react, but keeps its selection.
        #expect(fill(pressed: true, hovered: true, enabled: false) == nil)
        #expect(fill(selected: true, pressed: true, enabled: false) == .bgSelected)
    }

    @Test("Destructive rows take the danger colours; disabled rows the disabled ones")
    func colours() {
        #expect(QeetrixListItemMetrics.titleColor(isEnabled: true, isDestructive: false) == .textDefault)
        #expect(QeetrixListItemMetrics.titleColor(isEnabled: true, isDestructive: true) == .textDanger)
        #expect(QeetrixListItemMetrics.titleColor(isEnabled: false, isDestructive: true) == .textDisabled)
        #expect(QeetrixListItemMetrics.iconColor(isEnabled: true, isDestructive: false) == .iconSubtle)
        #expect(QeetrixListItemMetrics.iconColor(isEnabled: true, isDestructive: true) == .iconDanger)
        #expect(QeetrixListItemMetrics.iconColor(isEnabled: false, isDestructive: false) == .iconDisabled)
    }

    @Test("A selected row is drawn on color.bg.selected")
    func selectedFill() throws {
        let image = try #require(Rendered(QeetrixListItem("Priya", isSelected: true).frame(width: 200).environment(\.colorScheme, .light)))
        #expect(close(QeetrixTheme.light.resolve(.bgSelected).bytes, image.pixel(190, 22)))
    }

    @Test("The icon tile: bg.neutral.subtle inside a border.subtle edge, 32 pt")
    func iconTile() throws {
        let image = try #require(Rendered(QeetrixListItemIcon(.lock).environment(\.colorScheme, .light)))
        #expect((image.width, image.height) == (32, 32))
        #expect(close(QeetrixTheme.light.resolve(.borderSubtle).bytes, image.pixel(16, 0)))
        #expect(close(QeetrixTheme.light.resolve(.bgNeutralSubtle).bytes, image.pixel(3, 3)))
    }

    @Test("The chevron sits at the end and mirrors in right-to-left layouts (menu.css scale: -1 1)")
    func chevronMirrors() throws {
        func render(_ direction: LayoutDirection) throws -> Rendered {
            try #require(
                Rendered(
                    QeetrixListItem(title: Text(verbatim: ""), accessory: .chevron).frame(width: 120)
                        .environment(\.colorScheme, .light).environment(\.layoutDirection, direction)))
        }
        let ltr = try render(.leftToRight)
        let rtl = try render(.rightToLeft)
        func inked(_ image: Rendered, _ x: Int) -> Bool {
            (0..<image.height).contains { image.pixel(x, $0).a > 0 }
        }
        // 16 pt in from the end: the chevron's 16 pt box is at 88–104 in LTR, 16–32 in RTL.
        #expect((88..<104).contains { inked(ltr, $0) })
        #expect(!(0..<60).contains { inked(ltr, $0) })
        #expect((16..<32).contains { inked(rtl, $0) })
        #expect(!(60..<120).contains { inked(rtl, $0) })
        // Mirrored drawing, not only mirrored placement: each pixel matches its mirror image.
        var mismatches = 0
        for y in 0..<ltr.height {
            for x in 0..<ltr.width where (ltr.pixel(x, y).a > 128) != (rtl.pixel(ltr.width - 1 - x, y).a > 128) {
                mismatches += 1
            }
        }
        #expect(mismatches <= 4)
    }

    @Test("The value sits at the end of the title's line, on its baseline; the description below")
    func textLayout() throws {
        func render(isStacked: Bool) throws -> Rendered {
            try #require(
                Rendered(
                    QeetrixListItemTextLayout(isStacked: isStacked, gap: 8) {
                        Color.red.frame(width: 50, height: 20).layoutValue(key: QeetrixListItemTextPart.self, value: .title)
                        Color.green.frame(width: 60, height: 16).layoutValue(key: QeetrixListItemTextPart.self, value: .description)
                        Color.blue.frame(width: 30, height: 16).layoutValue(key: QeetrixListItemTextPart.self, value: .metadata)
                    }
                    .frame(width: 200)))
        }
        let row = try render(isStacked: false)
        // A shape's baseline is its bottom: the 16 pt value ends where the 20 pt title does.
        #expect(row.height == 36)
        #expect(row.pixel(185, 12).b > 200 && row.pixel(185, 12).r < 50, "The value at the end of the first line")
        #expect(row.pixel(185, 2).a == 0, "On the title's baseline, not its top")
        #expect(row.pixel(10, 28).g > 150 && row.pixel(10, 28).r < 100, "The description under the line")
        let stacked = try render(isStacked: true)
        #expect(stacked.height == 52)
        #expect(stacked.pixel(10, 44).b > 200, "Stacked, the value follows the description")
    }

    @Test("At the accessibility sizes, trailing content moves below the text")
    func largeText() throws {
        func trailingColumns(_ size: DynamicTypeSize) throws -> [Int] {
            let image = try #require(
                Rendered(
                    QeetrixListItem("Storage", trailing: { Color.red.frame(width: 20, height: 20) })
                        .frame(width: 390).environment(\.dynamicTypeSize, size)))
            return (0..<image.width).filter { x in
                (0..<image.height).contains { y in image.pixel(x, y).r > 200 && image.pixel(x, y).g < 100 }
            }
        }
        #expect(try trailingColumns(.large).first == 390 - 16 - 20)
        #expect(try trailingColumns(.accessibility2).first == 16)
    }

    #if os(macOS)
        @Test("VoiceOver reads a row as one element: title, description, value, then the slots' text")
        func oneElement() {
            let elements = ListsAccessibilityTree.elements(
                of: QeetrixListItem("Storage", description: Text("Used this month"), metadata: Text("80 %")) {
                    QeetrixListItemIcon(.database)
                } trailing: {
                    QeetrixBadge("Pro")
                })
            #expect(elements.map(\.text) == ["Storage, Used this month, 80 %, Pro"], "\(elements)")
            #expect(elements.first?.role == "AXStaticText")
        }

        @Test("A button row is one button; a selected row is selected; a link row is a button")
        func buttonsAndLinks() {
            let button = ListsAccessibilityTree.elements(
                of: QeetrixListItem("Sign out", description: Text("On this device"), role: .destructive, action: {}))
            #expect(button.map(\.role) == ["AXButton"])
            #expect(button.map(\.text) == ["Sign out, On this device"])
            #expect(ListsAccessibilityTree.elements(of: QeetrixListItem("Priya", isSelected: true)).map(\.isSelected) == [true])
            #expect(ListsAccessibilityTree.elements(of: QeetrixListItem("Priya", isSelected: true, action: {})).map(\.isSelected) == [true])
            #expect(ListsAccessibilityTree.elements(of: QeetrixListItem("Priya")).map(\.isSelected) == [false])
            let link = ListsAccessibilityTree.elements(
                of: NavigationStack { QeetrixListItem("Account", description: Text("Name and email"), value: 1) })
            #expect(link.map(\.role) == ["AXButton"])
            #expect(link.map(\.text) == ["Account, Name and email"])
        }

        @Test("A switch row is read as the system's switch, with its state")
        func switchRow() {
            let on = ListsAccessibilityTree.elements(
                of: QeetrixListItem("Face ID", description: Text("Unlock with your face"), isOn: .constant(true)))
            #expect(on.map(\.text) == ["Face ID, Unlock with your face"])
            #expect(on.map(\.value) == ["1"])
            // The Mac draws the representation as its checkbox; iOS reads the same Toggle as a switch.
            #expect(on.map(\.role) == ["AXCheckBox"])
            #expect(ListsAccessibilityTree.elements(of: QeetrixListItem("Face ID", isOn: .constant(false))).map(\.value) == ["0"])
        }

        @Test("A control in trailing is offered as the row's action")
        func trailingControl() {
            let elements = ListsAccessibilityTree.elements(
                of: QeetrixListItem("Weekly digest", trailing: { QeetrixIconButton(.ellipsis, label: "More for Weekly digest") {} }))
            #expect(elements.count == 1)
            #expect(elements.first?.actions == ["More for Weekly digest"])
        }
    #endif

    @Test("Every form renders: content, button, link, switch, disabled and selected, with a style on any button")
    func renders() {
        let rows: [AnyView] = [
            AnyView(QeetrixListItem("Storage", description: Text("Used"), metadata: Text("2.4 GB"), accessory: .chevron)),
            AnyView(QeetrixListItem("Sign out", role: .destructive, action: {}) { QeetrixListItemIcon(.x) }),
            // A NavigationStack is hosted by the platform, which ImageRenderer doesn't draw; the link alone is.
            AnyView(QeetrixListItem("Account", value: 1) { QeetrixAvatar(name: "Priya Sharma", isDecorative: true) }),
            AnyView(QeetrixListItem("Face ID", isOn: .constant(true))),
            AnyView(QeetrixListItem("Managed", isOn: .constant(false)).disabled(true)),
            AnyView(QeetrixListItem("Priya", isSelected: true, action: {})),
            AnyView(
                Button {
                } label: {
                    QeetrixListItem("Invite a teammate")
                }.buttonStyle(.qeetrixListItem())),
            AnyView(List { QeetrixListItem("In a list") }.qeetrixListStyle().frame(height: 100)),
        ]
        for (index, row) in rows.enumerated() {
            #expect(ImageRenderer(content: row.frame(width: 390)).cgImage != nil, "row \(index)")
        }
    }
}
