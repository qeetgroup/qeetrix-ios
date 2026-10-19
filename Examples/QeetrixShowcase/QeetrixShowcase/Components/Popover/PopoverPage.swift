import Qeetrix
import SwiftUI

struct PopoverPage: View {
    @State private var showsRoles = false
    @State private var showsDetails = false

    var body: some View {
        ComponentPage(
            title: "Popover",
            summary: "Contextual content anchored to a control. A popover where there is room; a sheet on iPhone unless asked otherwise."
        ) {
            DemoSection("Help next to a label") {
                HStack(spacing: QeetrixSpacing.xs) {
                    QeetrixText("Roles")
                    QeetrixIconButton(.info, label: "About roles", size: .sm) { showsRoles = true }
                        .qeetrixPopover(isPresented: $showsRoles) {
                            Text("Roles").qeetrixTextStyle(.label)
                            Text("Admins can invite members and manage billing. Members can view and edit projects.")
                        }
                }
                QeetrixText("Portrait iPhone: a sheet. Landscape or iPad: a popover with an arrow.", variant: .muted)
            }
            DemoSection("A popover on iPhone too") {
                QeetrixButton("Show details", variant: .outline) { showsDetails = true }
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
