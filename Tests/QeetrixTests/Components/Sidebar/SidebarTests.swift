import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Sidebar and navigation scaffold")
struct SidebarTests {
    private enum Destination: Hashable { case accounts, devices, audit, settings }

    private let items = [
        QeetrixNavigationItem("Accounts", value: Destination.accounts, icon: .keyRound),
        QeetrixNavigationItem("Devices", value: Destination.devices, icon: .smartphone, badge: 2),
        QeetrixNavigationItem("Audit log", value: Destination.audit, icon: .fileText, isDisabled: true),
        QeetrixNavigationItem("Settings", value: Destination.settings, icon: .settings, filledWhenCurrent: false),
    ]

    @Test("An item is identified by its value, with its icon, count and state")
    func item() {
        #expect(items.map(\.id) == [.accounts, .devices, .audit, .settings])
        #expect(items[1].badge == 2 && items[0].badge == nil)
        #expect(items[2].isDisabled && !items[0].isDisabled)
        #expect(items[0].filledWhenCurrent && !items[3].filledWhenCurrent, "Filled when current by default")
    }

    @Test("The current item's icon is filled where it has a filled drawing and the item asks for it")
    func filledIcon() {
        #expect(items[0].iconVariant(isCurrent: true) == .filled)
        #expect(items[0].iconVariant(isCurrent: false) == .outline)
        #expect(items[3].iconVariant(isCurrent: true) == .outline, "filledWhenCurrent: false")
        let plus = QeetrixNavigationItem("New", value: 1, icon: .plus)
        #expect(!QeetrixIconName.plus.hasDrawing(.round, .filled))
        #expect(plus.iconVariant(isCurrent: true) == .outline, "No filled drawing: the outline, and the Ember bar marks it")
    }

    @Test("sidebar.css: the tint of the current item, hover and press; the colours of its text and icon")
    func states() {
        func state(current: Bool = false, enabled: Bool = true, pressed: Bool = false, hovered: Bool = false) -> QeetrixSidebarItemState {
            QeetrixSidebarItemState(isCurrent: current, isEnabled: enabled, isPressed: pressed, isHovered: hovered)
        }
        #expect(state().background == nil && state().foreground == .textSubtle)
        #expect(state(hovered: true).background == .overlayHover && state(hovered: true).foreground == .textDefault)
        #expect(state(pressed: true).background == .overlayPressed)
        #expect(state(current: true).background == .bgNeutralSubtleHover && state(current: true).foreground == .textDefault)
        #expect(state(current: true, pressed: true).background == .bgNeutralSubtleHover, "The current item rests on its tint")
        #expect(state(enabled: false, hovered: true).background == nil && state(enabled: false).foreground == .textDisabled)
        #expect(QeetrixSidebarMetrics.iconColor(isCurrent: false, isEnabled: true) == .iconSubtle)
        #expect(QeetrixSidebarMetrics.iconColor(isCurrent: true, isEnabled: true) == .iconBrand)
        #expect(QeetrixSidebarMetrics.iconColor(isCurrent: false, isEnabled: false) == .iconDisabled)
    }

    @Test("sidebar.css metrics: 10 pt gaps, 16 and 12 pt padding, label.md at 600 when current, 44 pt rows")
    func metrics() throws {
        #expect(QeetrixSidebarMetrics.gap == 10)
        #expect(QeetrixSidebarMetrics.leadingPadding == 16 && QeetrixSidebarMetrics.trailingPadding == 12)
        #expect(QeetrixSidebarMetrics.labelType == QeetrixTypeSpec(.labelMd))
        #expect(QeetrixSidebarMetrics.currentType.tokens.weight == .semibold)
        for density in QeetrixDensity.allCases {
            #expect(QeetrixSidebarMetrics.rowHeight(density) == max(44, density.sizeControlLg))
        }
        // component.sidebar.width-expanded, which iOS restates rather than generates (ADR 0018).
        let root = try Repository.stylesheet(block: ":root")
        #expect(root["--qx-component-sidebar-width-expanded"] == "16rem")
        #expect(QeetrixSidebarMetrics.width == 256, "16rem")
    }

    @Test("The current row: the 3 pt Ember bar on the leading edge, over the neutral tint")
    func currentRow() throws {
        func render(current: Bool, direction: LayoutDirection = .leftToRight) throws -> Rendered {
            let row = QeetrixSidebarRow(item: items[0], isCurrent: current) {}
                .frame(width: 256)
                .environment(\.colorScheme, .light)
                .environment(\.layoutDirection, direction)
            return try #require(Rendered(row))
        }
        let brand = QeetrixTheme.light.resolve(.borderBrand).bytes
        let tint = QeetrixTheme.light.resolve(.bgNeutralSubtleHover).bytes
        let current = try render(current: true)
        #expect(current.height == 44)
        #expect(close(brand, current.pixel(1, 22)))
        #expect(close(brand, current.pixel(2, 22)))
        #expect(close(tint, current.pixel(4, 22)), "3 pt, no more")
        #expect(close(tint, current.pixel(250, 2)))
        let mirrored = try render(current: true, direction: .rightToLeft)
        #expect(close(brand, mirrored.pixel(254, 22)), "On the leading edge in right to left")
        let other = try render(current: false)
        #expect(other.pixel(1, 22).a == 0 && other.pixel(250, 2).a == 0, "No bar and no tint")
    }

    @Test("Choosing a row sets the selection; a disabled one can't be chosen")
    func choosing() {
        #expect(QeetrixNavigationScaffold<Destination, EmptyView>.canChoose(.devices, in: items))
        #expect(!QeetrixNavigationScaffold<Destination, EmptyView>.canChoose(.audit, in: items), "Disabled")
        #expect(!QeetrixNavigationScaffold<Destination, EmptyView>.canChoose(.settings, in: Array(items.prefix(2))), "Not listed")
        var selection = Destination.accounts
        let binding = Binding(get: { selection }, set: { selection = $0 })
        let scaffold = QeetrixNavigationScaffold("Qeet Auth", selection: binding, items: items) { _ in EmptyView() }
        scaffold.choosable(showing: nil).wrappedValue = .audit
        #expect(selection == .accounts, "The disabled destination is refused")
        var column = NavigationSplitViewColumn.sidebar
        let columnBinding = Binding(get: { column }, set: { column = $0 })
        scaffold.choosable(showing: columnBinding).wrappedValue = .devices
        #expect(selection == .devices && column == .detail, "A collapsed split view shows the destination chosen")
    }

    @Test("The tab bar at compact width, the sidebar at regular width, unless the layout is fixed")
    func layout() {
        #expect(QeetrixNavigationLayout.allCases.map(\.rawValue) == ["automatic", "bar", "sidebar"])
        #expect(QeetrixNavigationLayout.automatic.resolved(for: .compact) == .bar)
        #expect(QeetrixNavigationLayout.automatic.resolved(for: nil) == .bar)
        #expect(QeetrixNavigationLayout.automatic.resolved(for: .regular) == .sidebar)
        #expect(QeetrixNavigationLayout.bar.resolved(for: .regular) == .bar)
        #expect(QeetrixNavigationLayout.sidebar.resolved(for: .compact) == .sidebar)
    }

    @Test("The rows render, light and dark; the scaffold builds in both layouts")
    func renders() {
        for scheme in [ColorScheme.light, .dark] {
            let list = QeetrixSidebarList(selection: .constant(Destination.devices), items: items)
                .frame(width: 256)
                .environment(\.colorScheme, scheme)
            #expect(ImageRenderer(content: list).cgImage != nil)
        }
        // A TabView and a NavigationSplitView are hosted by UIKit, which ImageRenderer does not draw;
        // building them is the check.
        for layout in QeetrixNavigationLayout.allCases {
            let scaffold = QeetrixNavigationScaffold(
                "Qeet Auth", selection: .constant(Destination.accounts), items: items, layout: layout
            ) { destination in
                NavigationStack { Text("\(String(describing: destination))") }
            }
            _ = scaffold.body
        }
        _ = QeetrixSidebar("Qeet Auth", selection: .constant(Destination.accounts), items: items).body
    }
}
