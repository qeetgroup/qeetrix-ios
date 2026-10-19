import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Tabs")
struct TabsTests {
    private enum Section: Hashable { case overview, activity, settings }

    private let tabs = [
        QeetrixTab("Overview", value: Section.overview),
        QeetrixTab("Activity", value: Section.activity, icon: .bell),
        QeetrixTab("Settings", value: Section.settings, isDisabled: true),
    ]

    @Test("A tab is identified by its value")
    func tab() {
        #expect(tabs.map(\.id) == [.overview, .activity, .settings])
        #expect(tabs[1].icon == .bell)
        #expect(tabs[2].isDisabled)
        #expect(!tabs[0].isDisabled)
    }

    @Test("Metrics from the web: text-sm medium labels, a 3 pt well")
    func metrics() {
        #expect(QeetrixTabsMetrics.labelType.tokens.size == 14)
        #expect(QeetrixTabsMetrics.labelType.tokens.weight == .medium)
        #expect(QeetrixTabsMetrics.wellPadding == 3)
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

    @Test("Line: the selected tab carries the 2 pt brand indicator; the others none")
    func lineIndicator() throws {
        func button(selected: Bool) -> some View {
            QeetrixTabButton(tab: tabs[0], isSelected: selected, variant: .line, height: 40) {}
                .environment(\.colorScheme, .light)
        }
        let selected = try #require(Rendered(button(selected: true)))
        let brand = QeetrixColor.borderBrand.color(for: .light).resolve(in: EnvironmentValues()).bytes
        #expect(close(brand, selected.pixel(4, selected.height - 1)))
        #expect(close(brand, selected.pixel(4, selected.height - 2)))
        #expect(selected.pixel(4, selected.height - 3).a == 0, "2 pt, no more")
        let unselected = try #require(Rendered(button(selected: false)))
        #expect(unselected.pixel(4, unselected.height - 1).a == 0)
    }

    @Test("Default: the selected tab is the raised surface; the others are clear")
    func defaultSurface() throws {
        func button(selected: Bool) -> some View {
            QeetrixTabButton(tab: tabs[0], isSelected: selected, variant: .default, height: 26) {}
                .environment(\.colorScheme, .light)
        }
        let selected = try #require(Rendered(button(selected: true)))
        let elevated = QeetrixColor.surfaceElevated.color(for: .light).resolve(in: EnvironmentValues()).bytes
        #expect(close(elevated, selected.pixel(selected.width / 2, 3)))
        let unselected = try #require(Rendered(button(selected: false)))
        #expect(unselected.pixel(unselected.width / 2, 3).a == 0)
    }

    @Test("Tab bar helpers attach to a view")
    func tabBar() {
        let view = Text("Inbox").qeetrixTabItem("Inbox", icon: .inbox, badge: 3).qeetrixTabBar()
        #expect(ImageRenderer(content: view).cgImage != nil)
        #expect(QeetrixNavigationBarBackground.allCases == [.automatic, .canvas])
    }
}
