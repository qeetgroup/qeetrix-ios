import Qeetrix
import SwiftUI

struct PopoverPage: View {
    @State private var showsRoles = false
    @State private var showsDetails = false

    var body: some View {
        ComponentPage(
            title: "Popover",
            summary:
                "Contextual content on the overlay surface: a title, a line under it, the content. A popover where there is room; a sheet on iPhone unless asked otherwise."
        ) {
            DemoSection("Help next to a label") {
                HStack(spacing: QeetrixSpace.gapXs) {
                    QeetrixText("Roles")
                    QeetrixIconButton(.info, label: "About roles", tone: .neutral, size: .sm) { showsRoles = true }
                        .qeetrixPopover(isPresented: $showsRoles, title: Text("Roles"), description: Text("Who can do what")) {
                            Text("Admins can invite members and manage billing. Members can view and edit projects.")
                        }
                }
                QeetrixText("Portrait iPhone: a sheet. Landscape or iPad: the system popover.", size: .sm, tone: .subtle)
            }
            DemoSection("A popover on iPhone too") {
                QeetrixButton("Show details", variant: .ghost) { showsDetails = true }
                    .qeetrixPopover(isPresented: $showsDetails, arrowEdge: .bottom, compactAdaptation: .popover) {
                        Text("Last synced 2 minutes ago.")
                    }
            }
        }
    }
}

#Preview {
    NavigationStack { PopoverPage() }
}
