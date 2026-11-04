import Qeetrix
import SwiftUI

/// The documentation categories of ui.qeet.in, which group the index as the web docs do. Folders
/// follow component families instead (ADR 0007). A category with no pages yet is not shown.
enum ShowcaseCategory: String, CaseIterable, Identifiable {
    case actions = "Actions"
    case forms = "Forms & inputs"
    case dateTime = "Date & time"
    case dataDisplay = "Data display"
    case feedback = "Feedback"
    case overlays = "Overlays"
    case navigation = "Navigation"
    case layout = "Layout"
    case utilities = "Utilities"

    var id: Self { self }

    var entries: [ShowcaseEntry] {
        ShowcaseCatalog.components.filter { $0.category == self }
    }
}

/// One page of the showcase. `id` is the `-page` launch argument: `-page switch` opens the Switch page
/// directly, for UI tests and screenshots.
struct ShowcaseEntry: Identifiable, Hashable {
    let id: String
    let title: String
    let category: ShowcaseCategory?
    let page: @MainActor () -> AnyView

    init<Page: View>(_ id: String, _ title: String, _ category: ShowcaseCategory?, @ViewBuilder page: @escaping @MainActor () -> Page) {
        self.id = id
        self.title = title
        self.category = category
        self.page = { AnyView(page()) }
    }

    static func == (lhs: ShowcaseEntry, rhs: ShowcaseEntry) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
