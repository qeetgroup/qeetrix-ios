import Qeetrix
import SwiftUI

/// The index: the foundations, then every component, grouped by the web documentation's categories.
struct ShowcaseRoot: View {
    @Binding var mode: QeetrixThemeMode
    @State private var path: [ShowcaseEntry] = []

    private var foundations: ShowcaseEntry {
        ShowcaseEntry("foundations", "Foundations", nil) { [$mode] in FoundationsPage(mode: $mode) }
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    NavigationLink(foundations.title, value: foundations)
                }
                ForEach(ShowcaseCategory.allCases.filter { !$0.entries.isEmpty }) { category in
                    Section(category.rawValue) {
                        ForEach(category.entries) { entry in
                            NavigationLink(entry.title, value: entry)
                        }
                    }
                }
            }
            .navigationTitle("Qeetrix")
            .navigationDestination(for: ShowcaseEntry.self) { entry in
                entry.page()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("Theme", selection: $mode) {
                        ForEach(QeetrixThemeMode.allCases) { Text($0.rawValue.capitalized).tag($0) }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
        .tint(QeetrixColor.textBrand)
        .onAppear {
            // `-page <id>` opens one page directly.
            if path.isEmpty, let id = UserDefaults.standard.string(forKey: "page") {
                path = ([foundations] + ShowcaseCatalog.components).filter { $0.id == id }
            }
        }
    }
}
