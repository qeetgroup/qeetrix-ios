import Qeetrix
import SwiftUI

/// A long list of countries, languages in groups chosen several at a time, a directory searched on a
/// "server", and the trigger's read-only and disabled states.
struct ComboboxPage: View {
    @State private var country: String? = nil
    @State private var languages: Set<String> = ["en"]
    @State private var ownerID: Int? = nil
    @State private var owners = ComboboxPage.directory
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?

    private static let countryNames = [
        ("AR", "Argentina"), ("AU", "Australia"), ("AT", "Austria"), ("BD", "Bangladesh"), ("BE", "Belgium"), ("BT", "Bhutan"),
        ("BR", "Brazil"), ("CA", "Canada"), ("CL", "Chile"), ("CN", "China"), ("CO", "Colombia"), ("CI", "Côte d'Ivoire"),
        ("CZ", "Czechia"), ("DK", "Denmark"), ("EG", "Egypt"), ("FI", "Finland"), ("FR", "France"), ("DE", "Germany"),
        ("GR", "Greece"), ("HK", "Hong Kong"), ("IS", "Iceland"), ("IN", "India"), ("ID", "Indonesia"), ("IE", "Ireland"),
        ("IL", "Israel"), ("IT", "Italy"), ("JP", "Japan"), ("KE", "Kenya"), ("MY", "Malaysia"), ("MV", "Maldives"),
        ("MX", "Mexico"), ("NP", "Nepal"), ("NL", "Netherlands"), ("NZ", "New Zealand"), ("NG", "Nigeria"), ("NO", "Norway"),
        ("PH", "Philippines"), ("PL", "Poland"), ("PT", "Portugal"), ("QA", "Qatar"), ("RE", "Réunion"), ("SA", "Saudi Arabia"),
        ("SG", "Singapore"), ("ZA", "South Africa"), ("KR", "South Korea"), ("ES", "Spain"), ("LK", "Sri Lanka"),
        ("SE", "Sweden"), ("CH", "Switzerland"), ("TH", "Thailand"), ("TR", "Türkiye"), ("AE", "United Arab Emirates"),
        ("GB", "United Kingdom"), ("US", "United States"), ("VN", "Vietnam"),
    ]

    private let countries: [QeetrixComboboxItem<String?>] =
        ComboboxPage.countryNames.map { QeetrixComboboxItem($0.1, value: Optional($0.0)) }
        + [QeetrixComboboxItem("Antarctica", value: "AQ", description: "Not served yet", isDisabled: true)]

    private let languageGroups = [
        QeetrixComboboxGroup(
            "Indian languages",
            items: [
                QeetrixComboboxItem("Bengali", value: "bn", description: "বাংলা"),
                QeetrixComboboxItem("Hindi", value: "hi", description: "हिन्दी"),
                QeetrixComboboxItem("Kannada", value: "kn", description: "ಕನ್ನಡ"),
                QeetrixComboboxItem("Malayalam", value: "ml", description: "മലയാളം"),
                QeetrixComboboxItem("Marathi", value: "mr", description: "मराठी"),
                QeetrixComboboxItem("Tamil", value: "ta", description: "தமிழ்"),
                QeetrixComboboxItem("Telugu", value: "te", description: "తెలుగు"),
            ]),
        QeetrixComboboxGroup(
            "Other languages",
            items: [
                QeetrixComboboxItem("Arabic", value: "ar", description: "العربية"),
                QeetrixComboboxItem("English", value: "en"),
                QeetrixComboboxItem("French", value: "fr", description: "Français"),
                QeetrixComboboxItem("German", value: "de", description: "Deutsch"),
                QeetrixComboboxItem("Japanese", value: "ja", description: "日本語"),
            ]),
    ]

    /// A stand-in for a directory searched on a server.
    private static let people = [
        (1, "Priya Sharma", "priya@acme.in"), (2, "Rahul Verma", "rahul@acme.in"), (3, "Ananya Iyer", "ananya@acme.in"),
        (4, "Arjun Mehta", "arjun@acme.in"), (5, "Sofia Müller", "sofia@acme.de"), (6, "Kavya Reddy", "kavya@acme.in"),
        (7, "Rohan Das", "rohan@acme.in"), (8, "Zoë Laurent", "zoe@acme.fr"),
    ]
    private static let directory = people.map { QeetrixComboboxItem($0.1, value: Optional($0.0), description: $0.2) }

    var body: some View {
        ComponentPage(
            title: "Combobox",
            summary:
                "A choice from a long list, behind the Select's trigger: a sheet with a search field, groups, the choice marked, and No matches."
        ) {
            DemoSection("One choice") {
                QeetrixCombobox(
                    "Country", selection: $country, items: countries, placeholder: Text("e.g. India"), searchPrompt: Text("e.g. Germany"),
                    error: country == nil ? "Choose the country you're registered in." : nil, isRequired: true)
                QeetrixText("Selected: \(country ?? "none")", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("combobox-country-selected")
            }
            DemoSection("Several, in groups") {
                QeetrixCombobox(
                    "Languages you speak", selection: $languages, groups: languageGroups, placeholder: Text("e.g. Hindi"),
                    description: Text("Shown on your profile."), isOptional: true)
                QeetrixText("Selected: \(languages.sorted().joined(separator: ", "))", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("combobox-languages-selected")
            }
            DemoSection("Searched on a server") {
                QeetrixCombobox(
                    "Owner", selection: $ownerID, items: owners, placeholder: Text("e.g. Priya Sharma"),
                    searchPrompt: Text("Name or email"),
                    isLoading: isSearching
                ) { query in
                    search(query)
                }
            }
            DemoSection("Read-only and disabled") {
                QeetrixCombobox(
                    "Currency", selection: .constant("INR"), items: [QeetrixComboboxItem("Indian rupee", value: "INR")], isReadOnly: true)
                QeetrixCombobox("Time zone", selection: .constant("IST"), items: [QeetrixComboboxItem("India Standard Time", value: "IST")])
                    .disabled(true)
            }
        }
    }

    /// Answers after a short wait, as a server would; a new search cancels the one before it.
    private func search(_ query: String) {
        searchTask?.cancel()
        isSearching = true
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled else { return }
            let needle = query.trimmingCharacters(in: .whitespaces)
            owners = Self.directory.filter { item in
                needle.isEmpty || item.label.localizedStandardContains(needle)
                    || (item.description?.localizedStandardContains(needle) ?? false)
            }
            isSearching = false
        }
    }
}

#Preview {
    NavigationStack { ComboboxPage() }
}

#Preview("Large text, dark") {
    NavigationStack { ComboboxPage() }
        .environment(\.dynamicTypeSize, .accessibility3)
        .preferredColorScheme(.dark)
}
