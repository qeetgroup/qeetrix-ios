import Qeetrix
import SwiftUI

struct ToastPage: View {
    @State private var toast: QeetrixToast?
    @State private var undos = 0

    var body: some View {
        ComponentPage(
            title: "Toast",
            summary: "Brief feedback about an outcome, with a 3 pt status edge. One at a time; it leaves after 5 s, except danger."
        ) {
            DemoSection("Tones") {
                FlowLayout {
                    QeetrixButton("Info", variant: .ghost) { toast = QeetrixToast(.info, title: "Message archived") }
                    QeetrixButton("Success", variant: .ghost) {
                        toast = QeetrixToast(.success, title: "Settings saved", description: "They apply to new sessions.")
                    }
                    QeetrixButton("Warning", variant: .ghost) {
                        toast = QeetrixToast(.warning, title: "Saved offline", description: "Changes sync when you reconnect.")
                    }
                    QeetrixButton("Danger", variant: .ghost, tone: .danger) {
                        toast = QeetrixToast(.danger, title: "Report not sent", description: "Check your connection and try again.")
                    }
                }
                QeetrixText("A danger toast stays until it is dismissed.", size: .sm, tone: .subtle)
            }
            DemoSection("With an action") {
                QeetrixButton("Archive with undo", variant: .ghost) {
                    toast = QeetrixToast(.info, title: "Conversation archived", action: .init("Undo") { undos += 1 })
                }
                QeetrixText("Undone: \(undos)", size: .sm, tone: .subtle).accessibilityIdentifier("toast-undos")
            }
            DemoSection("Timing") {
                FlowLayout {
                    QeetrixButton("Brief, 2 s", variant: .ghost) {
                        toast = QeetrixToast(.success, title: "Link copied", duration: .seconds(2))
                    }
                    QeetrixButton("Until dismissed", variant: .ghost) {
                        toast = QeetrixToast(.info, title: "Sync paused", description: "Resume it in settings.", duration: .zero)
                    }
                }
            }
            QeetrixText("Showing: \(toast?.title ?? "nothing")", size: .sm, tone: .subtle).accessibilityIdentifier("toast-state")
        }
        .qeetrixToast($toast)
    }
}

#Preview {
    NavigationStack { ToastPage() }
}
