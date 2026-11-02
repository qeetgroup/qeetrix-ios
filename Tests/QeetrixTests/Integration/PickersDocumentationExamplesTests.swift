import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing
import UniformTypeIdentifiers

// The examples from Sources/Qeetrix/Qeetrix.docc/Components — Combobox.md and FileUpload.md — and from
// the doc comments of QeetrixCombobox, QeetrixComboboxItem, QeetrixFileUpload, QeetrixFileRow and
// QeetrixFileLimits, copied verbatim inside views that supply the names they use. If the API changes in
// a way that breaks an example, this file stops compiling, and the page must be updated with it.

private struct Member: Identifiable {
    let id: Int
    let name: String
    let email: String
}

/// Combobox.md.
private struct ComboboxExamples: View {
    @State private var country: String? = nil
    @State private var languages: Set<String> = ["en"]
    @State private var ownerID: Int? = nil
    @State private var isSearching = false
    let results = [QeetrixComboboxItem("Priya Sharma", value: Optional(1), description: "priya@acme.in")]

    var body: some View {
        let countries: [QeetrixComboboxItem<String?>] = [
            QeetrixComboboxItem("India", value: "IN"),
            QeetrixComboboxItem("Germany", value: "DE", description: "Deutschland"),
            QeetrixComboboxItem("United Arab Emirates", value: "AE"),
        ]
        let groups = [
            QeetrixComboboxGroup(
                "Indian languages",
                items: [
                    QeetrixComboboxItem("Hindi", value: "hi", description: "हिन्दी"),
                    QeetrixComboboxItem("Tamil", value: "ta", description: "தமிழ்"),
                ]),
            QeetrixComboboxGroup(
                "Other languages",
                items: [
                    QeetrixComboboxItem("English", value: "en"),
                    QeetrixComboboxItem("German", value: "de", description: "Deutsch"),
                ]),
        ]
        VStack {
            QeetrixCombobox(
                "Country", selection: $country, items: countries, placeholder: Text("e.g. India"),
                searchPrompt: Text("e.g. Germany"))
            QeetrixCombobox("Languages you speak", selection: $languages, groups: groups, isOptional: true)
            QeetrixCombobox(
                "Owner", selection: $ownerID, items: results, placeholder: Text("e.g. Priya Sharma"),
                isLoading: isSearching
            ) { query in
                search(query)
            }
        }
    }

    func search(_ query: String) {}
}

/// The doc comments of QeetrixCombobox and QeetrixComboboxItem.
private struct ComboboxCommentExamples: View {
    @State private var country = "IN"
    @State private var languages: Set<String> = []
    let members = [Member(id: 1, name: "Priya Sharma", email: "priya@acme.in")]
    let countries = [QeetrixComboboxItem("India", value: "IN")]
    let languageGroups = [QeetrixComboboxGroup("Indian languages", items: [QeetrixComboboxItem("Hindi", value: "hi")])]

    var body: some View {
        let owners = members.map { QeetrixComboboxItem($0.name, value: $0.id, description: $0.email) }
        VStack {
            QeetrixCombobox("Country", selection: $country, items: countries, placeholder: Text("e.g. India"))
            QeetrixCombobox("Languages", selection: $languages, groups: languageGroups)
            QeetrixCombobox("Owner", selection: .constant(1), items: owners)
        }
    }
}

/// FileUpload.md, and the doc comments of QeetrixFileUpload, QeetrixFileRow and QeetrixFileLimits.
private struct FileUploadExamples: View {
    @State private var receipts: [QeetrixFileUploadItem] = []
    @Environment(\.locale) private var locale
    let invoice = QeetrixFileUploadItem(name: "invoice.pdf", size: 248_000, status: .done)
    let file = QeetrixFileUploadItem(name: "scan.pdf", size: 12_000_000)

    var body: some View {
        let limits = QeetrixFileLimits(allowedContentTypes: [.pdf, .png], maxSize: 10_000_000)
        let hint = limits.hint(locale: locale)  // "PDF or PNG, up to 10 MB"
        VStack {
            QeetrixFileUpload(
                "Receipts", files: $receipts, allowedContentTypes: [.pdf, .jpeg, .png], maxSize: 10_000_000,
                allowsMultiple: true
            ) { chosen in
                for file in chosen { upload(file) }
            }
            QeetrixFileRow(invoice) { remove(invoice) }
            QeetrixText(hint ?? "")
            QeetrixText(limits.problem(for: file, locale: locale) ?? "")
        }
    }

    func upload(_ file: QeetrixFileUploadItem) {}
    func remove(_ file: QeetrixFileUploadItem) {}
}

@MainActor
@Suite("Picker documentation examples")
struct PickersDocumentationExamplesTests {
    @Test("Every picker example compiles against the public API and renders, in both themes")
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: ComboboxExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: ComboboxCommentExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: FileUploadExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
        }
    }

    @Test("The limits' example says what its comment says")
    func limitsExample() {
        let limits = QeetrixFileLimits(allowedContentTypes: [.pdf, .png], maxSize: 10_000_000)
        #expect(limits.hint(locale: Locale(identifier: "en_IN")) == "PDF or PNG, up to 10 MB")
        let file = QeetrixFileUploadItem(name: "scan.pdf", size: 12_000_000)
        #expect(limits.problem(for: file, locale: Locale(identifier: "en_IN")) == "Larger than 10 MB")
    }
}
