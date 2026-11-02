import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from Chip.md, SegmentedControl.md, Accordion.md, AvatarGroup.md and PageIndicator.md in
// Sources/Qeetrix/Qeetrix.docc/Components, copied verbatim inside views that supply the names they use.
// If the API changes in a way that breaks an example, this file stops compiling, and the page must be
// updated with it.

private enum Status: Hashable { case open, closed }
private enum Filter: Hashable { case all, pending }
private enum Scheme: Hashable { case light, dark, system }
private enum Section: Hashable { case tax, numbering, reminders }

/// Chip.md.
private struct ChipExamples: View {
    @State private var unread = false
    @State private var mentions = true
    @State private var status: Status? = nil
    @State private var departments: Set<String> = ["eng"]
    @State private var starred = false
    let departmentOptions = [QeetrixOption("Engineering", value: "eng"), QeetrixOption("Finance", value: "fin")]

    var body: some View {
        VStack {
            QeetrixChipFlowLayout {
                QeetrixChip("Unread", isSelected: $unread)
                QeetrixChip("Mentions", isSelected: $mentions, icon: .bell)
                QeetrixChip("Status: Active") { removeStatusFilter() }
            }
            QeetrixChipGroup(
                "Status", selection: $status,
                options: [
                    QeetrixOption("All", value: nil),
                    QeetrixOption("Open", value: .open),
                    QeetrixOption("Closed", value: .closed),
                ],
                size: .sm)
            QeetrixChipGroup("Departments", selection: $departments, options: departmentOptions, overflow: .scroll)
            Toggle("Starred", isOn: $starred)
                .toggleStyle(.qeetrixChip(icon: .pin))
        }
    }

    func removeStatusFilter() {}
}

/// SegmentedControl.md.
private struct SegmentedControlExamples: View {
    @State private var filter = Filter.all
    @State private var scheme = Scheme.system

    var body: some View {
        VStack {
            QeetrixSegmentedControl(
                "Show", selection: $filter,
                options: [
                    QeetrixOption("All", value: Filter.all),
                    QeetrixOption("Pending", value: Filter.pending),
                ])
            QeetrixSegmentedControl(
                "Theme", selection: $scheme,
                options: [
                    QeetrixOption("Light", value: Scheme.light),
                    QeetrixOption("Dark", value: Scheme.dark),
                    QeetrixOption("System", value: Scheme.system),
                ],
                size: .sm)
        }
    }
}

/// Accordion.md: one section at a time.
private struct AccordionExamples: View {
    @State private var open: Section? = .tax
    @State private var showsAdvanced = false
    @State private var retries = true
    @State private var showsRetries = false

    var body: some View {
        VStack {
            QeetrixAccordion(expanded: $open) {
                QeetrixAccordionItem("Tax settings", value: Section.tax) {
                    QeetrixText("GST is added at 18%.")
                }
                QeetrixAccordionItem("Invoice numbering", value: Section.numbering) {
                    QeetrixText("INV-YYYY-NNNN")
                }
            }
            QeetrixAccordionItem("Advanced options", isExpanded: $showsAdvanced) {
                QeetrixSwitch("Retry failed webhooks", isOn: $retries)
            }
            DisclosureGroup("Retry policy", isExpanded: $showsRetries) {
                QeetrixText("Three attempts, a minute apart.")
            }
            .disclosureGroupStyle(.qeetrixAccordion())
        }
    }
}

/// Accordion.md: any number of sections.
private struct AccordionMultipleExamples: View {
    @State private var open: Set<Section> = [.tax]

    var body: some View {
        QeetrixAccordion(expanded: $open) {
            QeetrixAccordionItem("Tax settings", value: Section.tax) { QeetrixText("GST is added at 18%.") }
            QeetrixAccordionItem("Reminders", value: Section.reminders) { QeetrixText("Off") }
                .disabled(true)
        }
    }
}

/// AvatarGroup.md.
private struct AvatarGroupExamples: View {
    let products = ["Pay", "People", "Logs", "Notify", "ID"]

    var body: some View {
        VStack {
            QeetrixAvatarGroup(
                people: [
                    QeetrixAvatarGroupPerson(name: "Priya Sharma"),
                    QeetrixAvatarGroupPerson(name: "Rahul Verma"),
                    QeetrixAvatarGroupPerson(name: "Ananya Iyer"),
                ],
                total: 412)
            QeetrixAvatarGroup(
                people: products.map { QeetrixAvatarGroupPerson(name: $0) },
                size: .lg, shape: .square,
                label: Text("5 applications: Pay, People, Logs, Notify and ID"))
        }
    }
}

/// PageIndicator.md. The page style of `TabView` is iOS-only; the guard lets this file also build on
/// the Mac host, and is the one difference from the page.
private struct PageIndicatorExamples: View {
    struct Slide { let title: String }
    struct SlideView: View {
        let slide: Slide
        var body: some View { QeetrixText(slide.title) }
    }

    @State private var page = 0
    let slides = [Slide(title: "Sign in with a passkey"), Slide(title: "Approve from your phone"), Slide(title: "You're set")]

    var body: some View {
        VStack {
            #if os(iOS)
                TabView(selection: $page) {
                    ForEach(slides.indices, id: \.self) { index in
                        SlideView(slide: slides[index]).tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
            QeetrixPageIndicator(page: $page, count: slides.count)
        }
    }
}

@Suite("Selection documentation examples")
struct SelectionDocumentationExamplesTests {
    @Test("Every selection and disclosure example compiles against the public API and renders, in both themes")
    @MainActor
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: ChipExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: SegmentedControlExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: AccordionExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: AccordionMultipleExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: AvatarGroupExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(
                ImageRenderer(content: PageIndicatorExamples().frame(width: 390, height: 300).qeetrixThemeMode(theme)).cgImage != nil)
        }
    }
}
