import Qeetrix
import SwiftUI

struct PageIndicatorPage: View {
    private let slides = [
        ("Sign in with a passkey", "No password to remember or type."),
        ("Approve from your phone", "A tap confirms it's you."),
        ("Stay signed in", "On every device you trust."),
        ("You're set", "Manage your devices any time in Settings."),
    ]

    @State private var page = 0
    @State private var many = 5

    var body: some View {
        ComponentPage(
            title: "Page indicator",
            summary:
                "Where you are in paged content: a mark per page, the current one wide and in Ember. A tap moves a page; VoiceOver reads \"Page 1 of 4\"."
        ) {
            DemoSection("With paged content") {
                TabView(selection: $page) {
                    ForEach(slides.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                            QeetrixHeading(slides[index].0, level: 3, size: .titleMd)
                            QeetrixText(slides[index].1, tone: .subtle)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(QeetrixSpace.insetLg)
                        .background(QeetrixColor.surfaceRaised)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 160)
                QeetrixPageIndicator(page: $page, count: slides.count, label: Text("Onboarding"))
                    .frame(maxWidth: .infinity)
                QeetrixText("Page \(page + 1)", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("page-indicator-page")
            }
            DemoSection("Eight pages") {
                QeetrixPageIndicator(page: $many, count: 8)
            }
            DemoSection("Disabled") {
                QeetrixPageIndicator(page: .constant(1), count: 4).disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { PageIndicatorPage() }
}
