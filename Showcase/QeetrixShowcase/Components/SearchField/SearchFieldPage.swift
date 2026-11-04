import Qeetrix
import SwiftUI

/// The search field's states, a list it searches after a pause, and the system search bar with the same
/// behaviour one level down.
struct SearchFieldPage: View {
    static let members = ["Asha Rao", "Ravi Kumar", "Priya Sharma", "Arjun Mehta", "Meera Iyer", "Kabir Singh"]

    @State private var query = ""
    @State private var results = SearchFieldPage.members
    @State private var searches = 0
    @State private var labelled = "asha@acme.in"

    var body: some View {
        ComponentPage(
            title: "Search field",
            summary:
                "A search box for a list: the field with a search icon and Clear search. It searches when typing pauses, on the search key, and when cleared."
        ) {
            DemoSection("Search a list") {
                QeetrixSearchField(text: $query, prompt: Text("e.g. Asha")) { query in
                    searches += 1
                    results = Self.members.filter { query.isEmpty || $0.localizedStandardContains(query) }
                }
                .accessibilityIdentifier("search-field")
                QeetrixText("Searches run: \(searches)", size: .sm, tone: .subtle).accessibilityIdentifier("search-count")
                ForEach(results, id: \.self) { member in
                    QeetrixText(member)
                }
                if results.isEmpty {
                    QeetrixText("No members match", tone: .subtle)
                }
            }
            DemoSection("States") {
                QeetrixSearchField("Find a member", text: $labelled, description: Text("Name or email."))
                QeetrixSearchField(text: .constant("Asha"), isReadOnly: true)
                QeetrixSearchField(text: .constant("Asha")).disabled(true)
            }
            DemoSection("The system search bar") {
                NavigationLink {
                    SystemSearchDemo()
                } label: {
                    QeetrixText("Open a list with the search bar")
                }
            }
        }
    }
}

/// A list with the system search bar, searched with the field's behaviour.
private struct SystemSearchDemo: View {
    @State private var query = ""
    @State private var results = SearchFieldPage.members

    var body: some View {
        List(results, id: \.self) { member in
            Text(member).qeetrixTextStyle(.bodyMd)
        }
        .navigationTitle("Members")
        .qeetrixSearchable(text: $query, prompt: Text("e.g. Asha")) { query in
            results = SearchFieldPage.members.filter { query.isEmpty || $0.localizedStandardContains(query) }
        }
        .qeetrixNavigationBar(title: .qeetrix)
    }
}

#Preview {
    NavigationStack { SearchFieldPage() }
}
