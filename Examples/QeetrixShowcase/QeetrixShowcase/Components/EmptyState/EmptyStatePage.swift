import Qeetrix
import SwiftUI

struct EmptyStatePage: View {
    @State private var created = 0

    var body: some View {
        ComponentPage(
            title: "Empty state",
            summary: "What a surface shows when there is nothing to show. The variant says why; the words and actions are the app's."
        ) {
            DemoSection("First use") {
                QeetrixCard {
                    QeetrixEmptyState(
                        "No invoices yet", description: Text("Invoices appear here once you bill a customer."), variant: .firstUse,
                        icon: .fileText
                    ) {
                        QeetrixButton("Create invoice") { created += 1 }
                    }
                }
                QeetrixText("Created: \(created)", variant: .muted).accessibilityIdentifier("empty-created")
            }
            DemoSection("No results, small") {
                QeetrixCard {
                    QeetrixEmptyState("No results", description: Text("Nothing matches “roadmap”."), variant: .noResults, size: .sm)
                }
            }
            DemoSection("No permission") {
                QeetrixCard {
                    QeetrixEmptyState(
                        "You can't see these reports", description: Text("Ask a workspace admin for access."), variant: .noPermission)
                }
            }
            DemoSection("Error") {
                QeetrixCard {
                    QeetrixEmptyState("Couldn't load reports", description: Text("Check your connection and try again."), variant: .error) {
                        QeetrixButton("Try again", leadingIcon: .refreshCw, variant: .outline) {}
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack { EmptyStatePage() }
}
