import Qeetrix
import SwiftUI

struct ToastPage: View {
    @State private var toast: QeetrixToast?
    @State private var undos = 0

    var body: some View {
        ComponentPage(
            title: "Toast",
            summary: "Brief feedback about an outcome. One at a time — a new one replaces the last — and it leaves by itself."
        ) {
            DemoSection("Types") {
                FlowLayout {
                    QeetrixButton("Info", variant: .outline) { toast = QeetrixToast(.info, title: "Message archived") }
                    QeetrixButton("Success", variant: .outline) {
                        toast = QeetrixToast(.success, title: "Settings saved", description: "They apply to new sessions.")
                    }
                    QeetrixButton("Warning", variant: .outline) {
                        toast = QeetrixToast(.warning, title: "Saved offline", description: "Changes sync when you reconnect.")
                    }
                    QeetrixButton("Error", variant: .outline) {
                        toast = QeetrixToast(.error, title: "Report not sent", description: "Check your connection and try again.")
                    }
                }
            }
            DemoSection("With an action") {
                QeetrixButton("Archive with undo", variant: .outline) {
                    toast = QeetrixToast(.info, title: "Conversation archived", action: .init("Undo") { undos += 1 })
                }
                QeetrixText("Undone: \(undos)", variant: .muted).accessibilityIdentifier("toast-undos")
            }
            DemoSection("Timing") {
                FlowLayout {
                    QeetrixButton("Brief, 2 s", variant: .outline) {
                        toast = QeetrixToast(.success, title: "Link copied", duration: .seconds(2))
                    }
                    QeetrixButton("Until closed", variant: .outline) {
                        toast = QeetrixToast(.info, title: "Sync paused", description: "Resume it in settings.", duration: .zero)
                    }
                }
            }
            QeetrixText("Showing: \(toast?.title ?? "nothing")", variant: .muted).accessibilityIdentifier("toast-state")
        }
        .qeetrixToast($toast)
    }
}

#Preview {
    NavigationStack { ToastPage() }
}
