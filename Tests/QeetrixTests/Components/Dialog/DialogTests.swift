import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Alert and confirmation dialogs")
struct DialogTests {
    @Test("A destructive action without a cancel gets one; otherwise the actions are kept")
    func resolution() {
        let delete = QeetrixDialogAction("Delete", role: .destructive)
        let keep = QeetrixDialogAction("Keep", role: .cancel)
        let save = QeetrixDialogAction("Save")
        let added = QeetrixDialogAction.resolved([delete])
        #expect(added.map(\.role) == [.destructive, .cancel])
        #expect(QeetrixDialogAction.resolved([delete, keep]).map(\.id) == [delete.id, keep.id])
        #expect(QeetrixDialogAction.resolved([save]).map(\.id) == [save.id])
        #expect(QeetrixDialogAction.resolved([]).isEmpty, "With none, the system shows OK")
    }

    @Test("A tap clears the presentation first, then runs the action once")
    func trigger() {
        final class Box {
            var alert: QeetrixAlertDialog?
            var runs = 0
            var clearedFirst = false
        }
        let box = Box()
        let action = QeetrixDialogAction("Delete", role: .destructive) {
            box.runs += 1
            box.clearedFirst = box.alert == nil
        }
        box.alert = QeetrixAlertDialog("Delete this workspace?", actions: [action])
        action.trigger(dismissing: Binding(get: { box.alert }, set: { box.alert = $0 }))
        #expect(box.alert == nil)
        #expect(box.runs == 1)
        #expect(box.clearedFirst, "The action sees the dialog gone")
    }

    @Test("Alert and confirmation values carry their content and are distinct")
    func values() {
        let alert = QeetrixAlertDialog("Delete?", message: Text("It cannot be undone."), actions: [.init("Delete", role: .destructive)])
        #expect(alert.message != nil)
        #expect(alert.actions.count == 1)
        #expect(alert.id != QeetrixAlertDialog("Delete?").id)
        let dialog = QeetrixConfirmationDialog("Share report", actions: [.init("Copy link"), .init("Email")])
        #expect(dialog.message == nil)
        #expect(dialog.actions.count == 2)
    }

    @Test("The modifiers attach without presenting")
    func attaches() {
        let view = Text("Content")
            .qeetrixAlertDialog(.constant(nil))
            .qeetrixConfirmationDialog(.constant(nil))
        #expect(ImageRenderer(content: view).cgImage != nil)
    }
}
