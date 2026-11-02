import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Tabs")
struct TabsTests {
    private enum Section: Hashable { case overview, activity, settings }

    private let tabs = [
        QeetrixTab("Overview", value: Section.overview),
        QeetrixTab("Activity", value: Section.activity, icon: .bell, filledWhenSelected: true, badge: 3),
        QeetrixTab("Settings", value: Section.settings, isDisabled: true),
    ]

    @Test("A tab is identified by its value, with its icon, badge and state")
    func tab() {
        #expect(tabs.map(\.id) == [.overview, .activity, .settings])
        #expect(tabs[1].icon == .bell && tabs[1].filledWhenSelected && tabs[1].badge == 3)
        #expect(tabs[2].isDisabled && !tabs[0].isDisabled)
        // The selected tab shows its icon filled unless asked not to, as react 0.4.0 (QTRX-168).
        #expect(QeetrixTab("Settings", value: 1, icon: .settings).filledWhenSelected)
        #expect(!QeetrixTab("Settings", value: 1, icon: .settings, filledWhenSelected: false).filledWhenSelected)
        #expect(QeetrixTabsVariant.allCases.map(\.rawValue) == ["line", "contained"])
    }

    @Test("tabs.css: 16 pt inline padding, 12 pt at compact (clamp(12px, control.lg − 20px, 16px))")
    func inset() {
        #expect(QeetrixTabs<Section>.inset(.compact) == 12)
        #expect(QeetrixTabs<Section>.inset(.default) == 16)
        #expect(QeetrixTabs<Section>.inset(.comfortable) == 16)
    }

    @Test("label.md; the selected tab at title.sm's 600")
    func type() {
        #expect(QeetrixTabsMetrics.labelType == QeetrixTypeSpec(.labelMd))
        #expect(QeetrixTabsMetrics.selectedType.tokens.weight == .semibold)
        #expect(QeetrixTabsMetrics.selectedType.tokens.size == QeetrixTextRole.labelMd.tokens.size)
    }

    @Test("Line: control.lg tall, the 3 pt Ember bar under the selected tab only")
    func line() throws {
        // The tab itself: the list is a horizontal scroll view, which ImageRenderer doesn't draw on the Mac.
        @Namespace var bar
        func button(selected: Bool) throws -> Rendered {
            let view = QeetrixTabButton(tab: tabs[0], isSelected: selected, variant: .line, height: 40, inset: 16, bar: bar) {}
                .environment(\.colorScheme, .light)
            return try #require(Rendered(view))
        }
        let selected = try button(selected: true)
        #expect(selected.height == 40)
        let brand = QeetrixTheme.light.resolve(.borderBrand).bytes
        #expect(close(brand, selected.pixel(selected.width / 2, selected.height - 1)))
        #expect(close(brand, selected.pixel(selected.width / 2, selected.height - 3)))
        #expect(selected.pixel(selected.width / 2, selected.height - 4).a == 0, "3 pt, no more")
        let unselected = try button(selected: false)
        #expect(unselected.pixel(unselected.width / 2, unselected.height - 1).a == 0)
    }

    @Test("Contained: the selected segment on surface.default, the others clear on the strip")
    func contained() throws {
        @Namespace var bar
        let view = QeetrixTabButton(tab: tabs[0], isSelected: true, variant: .contained, height: 38, inset: 16, bar: bar) {}
            .environment(\.colorScheme, .light)
        let image = try #require(Rendered(view))
        #expect(close(QeetrixTheme.light.resolve(.surfaceDefault).bytes, image.pixel(2, 2)))
        let plain = QeetrixTabButton(tab: tabs[0], isSelected: false, variant: .contained, height: 38, inset: 16, bar: bar) {}
        #expect(try #require(Rendered(plain)).pixel(2, 2).a == 0)
    }

    @Test("Both variants render, light and dark")
    func renders() {
        for variant in QeetrixTabsVariant.allCases {
            for scheme in [ColorScheme.light, .dark] {
                let view = QeetrixTabs(selection: .constant(Section.activity), tabs: tabs, variant: variant)
                    .frame(width: 360).environment(\.colorScheme, scheme)
                #expect(ImageRenderer(content: view).cgImage != nil)
            }
        }
    }

    @Test("Tab bar helpers attach to a view")
    func tabBar() {
        let view = Text("Inbox").qeetrixTabItem("Inbox", icon: .inbox, badge: 3).qeetrixTabBar()
        #expect(ImageRenderer(content: view).cgImage != nil)
        #expect(QeetrixNavigationBarBackground.allCases == [.automatic, .canvas])
    }
}
