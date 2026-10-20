import Qeetrix
import SwiftUI

/// The system navigation and tab bars with Qeetrix styling. The selected tab lives in this page's state,
/// so it survives closing and reopening the demo — the app owns navigation, not the design system.
struct AppNavigationPage: View {
    enum AppTab: String { case home, inbox, settings }

    @State private var tab = AppTab.home
    @State private var showsTabBar = false
    @State private var unread = 3

    var body: some View {
        ComponentPage(
            title: "App navigation",
            summary: "The system navigation and tab bars, with the Qeetrix tint, background and icons. Navigation state stays in the app."
        ) {
            DemoSection("Navigation bar") {
                NavigationLink {
                    NavigationBarDetail()
                } label: {
                    QeetrixText("Open a detail page")
                        .qeetrixMinimumTouchTarget()
                }
                QeetrixText("It sets qeetrixNavigationBar(background: .canvas) and a toolbar button with a Qeetrix icon.", variant: .muted)
            }
            DemoSection("Tab bar") {
                QeetrixButton("Open the tab bar", variant: .outline) { showsTabBar = true }
                QeetrixText("Selected tab: \(tab.rawValue)", variant: .muted)
                    .accessibilityIdentifier("selected-tab")
            }
        }
        .fullScreenCover(isPresented: $showsTabBar) {
            TabView(selection: $tab) {
                TabBarDemoTab(title: "Home", close: close)
                    .qeetrixTabItem("Home", icon: .house)
                    .tag(AppTab.home)
                TabBarDemoTab(title: "Inbox", close: close) {
                    QeetrixButton("Mark all as read", variant: .outline) { unread = 0 }
                }
                .qeetrixTabItem("Inbox", icon: .inbox, badge: unread)
                .tag(AppTab.inbox)
                TabBarDemoTab(title: "Settings", close: close)
                    .qeetrixTabItem("Settings", icon: .settings)
                    .tag(AppTab.settings)
            }
            .qeetrixTabBar()
        }
    }

    private func close() {
        showsTabBar = false
    }
}

/// One tab's root: its own navigation stack, as each tab of an app has.
private struct TabBarDemoTab<Extra: View>: View {
    let title: String
    let close: () -> Void
    let extra: Extra

    init(title: String, close: @escaping () -> Void, @ViewBuilder extra: () -> Extra = { EmptyView() }) {
        self.title = title
        self.close = close
        self.extra = extra()
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: QeetrixSpacing.m) {
                QeetrixText("\(title) content")
                    .accessibilityIdentifier("tab-content")
                extra
            }
            .padding(QeetrixSpacing.l)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(QeetrixColor.surfaceCanvas)
            .navigationTitle(title)
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
}

/// A pushed page with the canvas bar and a toolbar action.
private struct NavigationBarDetail: View {
    @State private var items = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixSpacing.m) {
                QeetrixText("Items: \(items)").accessibilityIdentifier("detail-items")
                QeetrixText("Swipe from the leading edge, or use the back button, to go back.", variant: .muted)
            }
            .padding(QeetrixSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    items += 1
                } label: {
                    Label {
                        Text("Add item")
                    } icon: {
                        Image(qeetrix: .plus)
                    }
                }
            }
        }
        .qeetrixNavigationBar(background: .canvas)
    }
}

#Preview {
    NavigationStack { AppNavigationPage() }
}
