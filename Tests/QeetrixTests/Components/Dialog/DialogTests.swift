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

    @Test("Text fields: up to two, the confirming action is the last that doesn't cancel, and waits for required fields")
    func textFields() {
        var issuer = "Acme"
        var account = ""
        let issuerField = QeetrixAlertTextField("Issuer", text: Binding(get: { issuer }, set: { issuer = $0 }))
        #expect(issuerField.contentType == nil && !issuerField.isSecure && !issuerField.isRequired)
        let accountField = QeetrixAlertTextField(
            label: Text("Account name"), text: Binding(get: { account }, set: { account = $0 }), contentType: .username, isRequired: true)
        let save = QeetrixDialogAction("Save")
        let rename = QeetrixAlertDialog(
            "Rename account", textFields: [issuerField, accountField], actions: [QeetrixDialogAction("Cancel", role: .cancel), save])
        #expect(rename.textFields.count == 2)
        #expect(rename.confirmingAction?.id == save.id)
        #expect(!rename.isComplete, "The account name is required and empty")
        account = "   "
        #expect(!rename.isComplete, "Spaces aren't a value")
        account = "priya@acme.in"
        #expect(rename.isComplete)
        issuer = ""
        #expect(rename.isComplete, "The issuer isn't required")

        let three = QeetrixAlertDialog(title: Text("Too many"), textFields: [issuerField, accountField, issuerField])
        #expect(three.textFields.count == 2, "The system alert holds two")
        #expect(three.confirmingAction == nil && three.isComplete)
        #expect(QeetrixAlertDialog("Delete?").textFields.isEmpty)
        let pin = QeetrixAlertTextField("PIN", text: .constant(""), contentType: .password, isSecure: true)
        #expect(pin.isSecure && pin.contentType == .password)
        #expect(
            QeetrixTextContentType.allCases.map(\.rawValue) == [
                "name", "organizationName", "username", "emailAddress", "url", "telephoneNumber", "password", "newPassword",
            ])
    }

    #if os(iOS)
        @Test("Each content type sets UIKit's type, the keyboard and the capitals")
        func contentTypes() {
            #expect(QeetrixTextContentType.username.uiContentType == .username)
            #expect(QeetrixTextContentType.url.uiContentType == .URL && QeetrixTextContentType.url.keyboardType == .URL)
            #expect(QeetrixTextContentType.emailAddress.keyboardType == .emailAddress)
            #expect(QeetrixTextContentType.telephoneNumber.keyboardType == .phonePad)
            #expect(QeetrixTextContentType.name.correctsSpelling && QeetrixTextContentType.organizationName.correctsSpelling)
            #expect(!QeetrixTextContentType.newPassword.correctsSpelling && !QeetrixTextContentType.emailAddress.correctsSpelling)
        }
    #endif

    @Test("The modifiers attach without presenting")
    func attaches() {
        let view = Text("Content")
            .qeetrixAlertDialog(.constant(nil))
            .qeetrixConfirmationDialog(.constant(nil))
        #expect(ImageRenderer(content: view).cgImage != nil)
    }
}
