import Foundation

/// Synthetic data for the data-display pages: made-up documents and people, nothing real.
struct ShowcaseDocument: Identifiable, Hashable {
    enum Status: String, CaseIterable, Hashable {
        case active = "Active"
        case draft = "Draft"
        case archived = "Archived"
    }

    let id: Int
    var title: String
    var owner: String
    var size: String
    var status: Status

    static let samples: [ShowcaseDocument] = [
        ShowcaseDocument(id: 1, title: "Q3 summary", owner: "Asha Rao", size: "2.4 MB", status: .active),
        ShowcaseDocument(id: 2, title: "Design review", owner: "Ravi Kumar", size: "860 KB", status: .draft),
        ShowcaseDocument(id: 3, title: "Roadmap", owner: "Meera Iyer", size: "1.1 MB", status: .active),
        ShowcaseDocument(id: 4, title: "Onboarding guide", owner: "Kabir Shah", size: "3.7 MB", status: .archived),
        ShowcaseDocument(id: 5, title: "Release notes", owner: "Asha Rao", size: "120 KB", status: .draft),
        ShowcaseDocument(id: 6, title: "Budget", owner: "Neha Singh", size: "640 KB", status: .active),
    ]

    /// `count` generated rows, the same every launch.
    static func generated(_ count: Int) -> [ShowcaseDocument] {
        let owners = ["Asha Rao", "Ravi Kumar", "Meera Iyer", "Kabir Shah", "Neha Singh"]
        return (1...count).map { index in
            ShowcaseDocument(
                id: index, title: "Document \(index)", owner: owners[index % owners.count], size: "\(index % 900 + 100) KB",
                status: Status.allCases[index % Status.allCases.count])
        }
    }
}
