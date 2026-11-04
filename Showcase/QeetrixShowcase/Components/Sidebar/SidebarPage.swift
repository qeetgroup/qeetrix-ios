import Qeetrix
import SwiftUI

/// The sidebar's rows, and the adaptive scaffold: a tab bar on iPhone, the sidebar beside the detail on
/// iPad. The destination lives in this page's state, so it survives closing and reopening the demo.
struct SidebarPage: View {
    enum Destination: String, CaseIterable { case accounts, devices, audit, settings }

    @State private var destination = Destination.accounts
    @State private var layout = QeetrixNavigationLayout.automatic
    @State private var showsScaffold = false

    var body: some View {
        ComponentPage(
            title: "Sidebar",
            summary:
                "An app's destinations: a tab bar at compact width, a sidebar beside the detail at regular width. The current item has the Ember bar, the tint and a filled icon."
        ) {
            DemoSection("Rows") {
                QeetrixSidebar("Qeet Auth", selection: $destination, items: items)
                    .frame(height: 4 * 44 + 20)
                    .overlay { Rectangle().strokeBorder(QeetrixColor.borderDefault, lineWidth: QeetrixBorderWidth.default) }
                QeetrixText("Current: \(destination.rawValue)", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("sidebar-current")
            }
            DemoSection("Adaptive layout") {
                QeetrixRadioGroup(
                    "Layout", selection: $layout,
                    options: [
                        QeetrixOption(
                            "Automatic", value: QeetrixNavigationLayout.automatic,
                            description: Text("The tab bar on iPhone, the sidebar on iPad")),
                        QeetrixOption("Tab bar", value: QeetrixNavigationLayout.bar),
                        QeetrixOption("Sidebar", value: QeetrixNavigationLayout.sidebar),
                    ])
                QeetrixButton("Open the adaptive layout", variant: .soft) { showsScaffold = true }
            }
        }
        .fullScreenCover(isPresented: $showsScaffold) {
            QeetrixNavigationScaffold("Qeet Auth", selection: $destination, items: items, layout: layout) { destination in
                NavigationStack {
                    ScaffoldDestination(destination: destination) { showsScaffold = false }
                }
            }
        }
    }

    private var items: [QeetrixNavigationItem<Destination>] {
        [
            QeetrixNavigationItem("Accounts", value: Destination.accounts, icon: .keyRound),
            QeetrixNavigationItem("Devices", value: Destination.devices, icon: .smartphone, badge: 2),
            QeetrixNavigationItem("Audit log", value: Destination.audit, icon: .fileText, isDisabled: true),
            QeetrixNavigationItem("Settings", value: Destination.settings, icon: .settings),
        ]
    }
}

/// One destination's root, with a Close button to leave the demo.
private struct ScaffoldDestination: View {
    let destination: SidebarPage.Destination
    let close: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
            QeetrixText("\(destination.rawValue.capitalized) content")
                .accessibilityIdentifier("scaffold-content")
            QeetrixText("Audit log is outside the plan: shown, but it can't be chosen.", size: .sm, tone: .subtle)
        }
        .padding(QeetrixSpace.insetLg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle(destination.rawValue.capitalized)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: close) {
                    Label {
                        Text("Close")
                    } icon: {
                        Image(qeetrix: .x)
                    }
                }
            }
        }
        .qeetrixNavigationBar()
    }
}

#Preview {
    NavigationStack { SidebarPage() }
}
