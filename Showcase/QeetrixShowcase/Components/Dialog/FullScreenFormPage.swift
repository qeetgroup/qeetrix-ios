import Qeetrix
import SwiftUI

/// A create flow and an edit flow. The page owns whether each form shows and the draft it edits; the
/// form asks before throwing changes away.
struct FullScreenFormPage: View {
    struct Contact: Identifiable, Equatable {
        var id = UUID()
        var name = ""
        var email = ""
        var notes = ""
    }

    @State private var contacts = [Contact(name: "Asha Rao", email: "asha@acme.in")]
    @State private var isAdding = false
    @State private var editing: Contact?
    @State private var draft = Contact()
    @State private var nameError: String?

    var body: some View {
        ComponentPage(
            title: "Full-screen form",
            summary:
                "A modal screen for creating or editing: Close, the title and the confirming action in its bar. The whole screen on iPhone, a form sheet on iPad."
        ) {
            DemoSection("Create") {
                QeetrixButton("New contact", icon: .userPlus, variant: .soft) {
                    draft = Contact()
                    nameError = nil
                    isAdding = true
                }
                QeetrixText("Type something, then Close: it asks before discarding.", size: .sm, tone: .subtle)
            }
            DemoSection("Edit") {
                ForEach(contacts) { contact in
                    QeetrixButton(contact.name, icon: .pencil, variant: .ghost) {
                        draft = contact
                        nameError = nil
                        editing = contact
                    }
                }
                QeetrixText("Contacts: \(contacts.count)", size: .sm, tone: .subtle).accessibilityIdentifier("contact-count")
            }
        }
        .qeetrixFullScreenForm(isPresented: $isAdding) {
            QeetrixFullScreenForm(
                "New contact", confirm: QeetrixScreenAction("Save") { save() }, hasChanges: draft != Contact(id: draft.id)
            ) {
                fields
            }
        }
        .qeetrixFullScreenForm(item: $editing) { contact in
            QeetrixFullScreenForm(
                "Edit contact", confirm: QeetrixScreenAction("Save", isDisabled: draft == contact) { save() }, hasChanges: draft != contact,
                discardTitle: Text("Discard your edits to \(contact.name)?")
            ) {
                fields
            }
        }
    }

    @ViewBuilder
    private var fields: some View {
        QeetrixTextField("Name", text: $draft.name, error: nameError, isRequired: true)
            .submitLabel(.next)
        QeetrixTextField("Email", text: $draft.email, prompt: Text("e.g. asha@acme.in"), isOptional: true)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
        QeetrixTextarea("Notes", text: $draft.notes, prompt: Text("e.g. Prefers email"), rows: 4, isOptional: true)
        ForEach(1...4, id: \.self) { line in
            QeetrixTextField("Extra field \(line)", text: .constant(""), isOptional: true)
        }
    }

    /// Validates, then saves and closes; a form with an error stays open to show it.
    private func save() {
        guard !draft.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            nameError = "Enter a name"
            return
        }
        nameError = nil
        if let index = contacts.firstIndex(where: { $0.id == draft.id }) {
            contacts[index] = draft
            editing = nil
        } else {
            contacts.append(draft)
            isAdding = false
        }
    }
}

#Preview {
    NavigationStack { FullScreenFormPage() }
}
