import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Combobox")
struct ComboboxTests {
    static let english = Locale(identifier: "en_IN")
    static let cities = [
        QeetrixComboboxItem("São Paulo", value: "sao"),
        QeetrixComboboxItem("München", value: "muc", description: "Bavaria"),
        QeetrixComboboxItem("İstanbul", value: "ist"),
        QeetrixComboboxItem("हिन्दी", value: "hi"),
        QeetrixComboboxItem("Zürich", value: "zrh", isDisabled: true),
    ]

    @Test("A search ignores case, accents and width, and the spaces around it")
    func matching() {
        func matches(_ label: String, _ query: String, _ locale: Locale = Self.english) -> Bool {
            QeetrixComboboxFilter.matches(label, query: query, locale: locale)
        }
        #expect(matches("São Paulo", "sao"))
        #expect(matches("München", "MUNCHEN"))
        #expect(matches("Zürich", "ZÜR"))
        #expect(matches("Café", "cafe\u{301}"), "Composed and decomposed accents are one letter")
        #expect(matches("ＡＢＣ Ltd", "abc"), "Full-width letters match their ASCII")
        #expect(matches("München", "  mün "))
        #expect(matches("München", ""), "An empty search matches everything")
        #expect(!matches("München", "Bavaria"), "The description isn't searched, as on the web")
        #expect(!matches("Kumar", "kumra"))
    }

    @Test("Letters compare as the environment's locale has them")
    func locale() {
        let turkish = Locale(identifier: "tr_TR")
        #expect(QeetrixComboboxFilter.matches("İstanbul", query: "istanbul", locale: turkish), "Turkish İ is i")
        #expect(!QeetrixComboboxFilter.matches("Kırıkkale", query: "kirikkale", locale: turkish), "Turkish ı isn't i")
        #expect(QeetrixComboboxFilter.matches("Kırıkkale", query: "KIRIK", locale: turkish), "Turkish I is ı")
    }

    @Test("An Indic query matches as it's typed, inside a conjunct, and keeps its vowel signs")
    func indic() {
        let hindi = Locale(identifier: "hi_IN")
        #expect(QeetrixComboboxFilter.matches("हिन्दी", query: "हिन", locale: hindi), "हिन is the start of हिन्दी")
        #expect(QeetrixComboboxFilter.matches("हिन्दी", query: "हिन्द", locale: hindi))
        #expect(!QeetrixComboboxFilter.matches("कुमार", query: "कमार", locale: hindi), "A vowel sign isn't an accent")
        #expect(QeetrixComboboxFilter.matches("தமிழ்", query: "தமி", locale: Locale(identifier: "ta_IN")))
    }

    @Test("Searching keeps a group's matching options and drops the groups left empty")
    func groups() {
        let sections = [
            QeetrixComboboxSection(QeetrixComboboxGroup("Europe", items: [QeetrixComboboxItem("Zürich", value: 1)])),
            QeetrixComboboxSection(
                QeetrixComboboxGroup("Asia", items: [QeetrixComboboxItem("Mumbai", value: 2), QeetrixComboboxItem("Muscat", value: 3)])),
        ]
        let found = QeetrixComboboxFilter.sections(sections, matching: "mu", locale: Self.english)
        #expect(found.map(\.label) == ["Asia"])
        #expect(found.first?.items.map(\.value) == [2, 3])
        #expect(QeetrixComboboxFilter.sections(sections, matching: "", locale: Self.english).count == 2)
        #expect(QeetrixComboboxFilter.sections(sections, matching: "xyz", locale: Self.english).isEmpty)
        #expect(
            QeetrixComboboxFilter.sections([QeetrixComboboxSection([QeetrixComboboxItem<Int>]())], matching: "", locale: Self.english)
                .isEmpty)
    }

    @Test("With onSearch the options are the server's results, shown as given")
    func serverSearch() {
        let sheet = QeetrixComboboxSheet(
            title: Text("City"), sections: [QeetrixComboboxSection(Self.cities)], selection: .single(.constant("muc")), searchPrompt: nil,
            isLoading: false, messages: QeetrixComboboxMessages(), searchDelay: .milliseconds(300), onSearch: { _ in }, query: "zzz")
        #expect(sheet.shown.first?.items.count == Self.cities.count)
        let local = QeetrixComboboxSheet(
            title: Text("City"), sections: [QeetrixComboboxSection(Self.cities)], selection: .single(.constant("muc")), searchPrompt: nil,
            isLoading: false, messages: QeetrixComboboxMessages(), searchDelay: .milliseconds(300), onSearch: nil, query: "zzz")
        #expect(local.shown.isEmpty)
    }

    @Test("One choice sets the value; several add and remove")
    func choosing() {
        var one = "sao"
        let single = QeetrixComboboxSelection.single(Binding(get: { one }, set: { one = $0 }))
        single.choose("muc")
        #expect(one == "muc" && single.contains("muc") && !single.contains("sao") && !single.isMultiple)

        var several: Set<String> = ["sao"]
        let multiple = QeetrixComboboxSelection.multiple(Binding(get: { several }, set: { several = $0 }))
        multiple.choose("muc")
        #expect(several == ["sao", "muc"] && multiple.isMultiple)
        multiple.choose("sao")
        #expect(several == ["muc"])
    }

    @Test("The trigger shows the choice, or with several the count, as react's multiple Combobox counts them")
    func triggerText() {
        let flat = [QeetrixComboboxSection(Self.cities)]
        func summary(
            _ selection: QeetrixComboboxSelection<String>, messages: QeetrixComboboxMessages = QeetrixComboboxMessages()
        )
            -> QeetrixComboboxSummary<String>
        {
            QeetrixComboboxSummary(selection: selection, sections: flat, messages: messages, locale: Self.english)
        }
        #expect(summary(.single(.constant("none"))).text == nil, "Nothing chosen: the placeholder")
        let one = summary(.single(.constant("muc")))
        #expect(one.text == "München" && one.accessibilityValue == "München")

        #expect(summary(.multiple(.constant([]))).text == nil)
        #expect(summary(.multiple(.constant(["muc"]))).text == "München", "One of several shows by name")
        let three = summary(.multiple(.constant(["zrh", "sao", "muc"])))
        #expect(three.text == "3 selected")
        #expect(three.chosenLabels == ["São Paulo", "München", "Zürich"], "In the options' order")
        // The labels follow as the locale writes a list ("…, München, and Zürich").
        let value = three.accessibilityValue ?? ""
        #expect(value.hasPrefix("3 selected, São Paulo, München") && value.hasSuffix("Zürich"))
        let worded = summary(.multiple(.constant(["sao", "muc"])), messages: QeetrixComboboxMessages(selected: { "\($0) cities" }))
        #expect(worded.text == "2 cities")
    }

    @Test("A choice a new search left out keeps the label seen before")
    func knownLabels() {
        var summary = QeetrixComboboxSummary(
            selection: .multiple(.constant(["muc", "del"])), sections: [QeetrixComboboxSection(Self.cities)], locale: Self.english)
        #expect(summary.chosenLabels == ["München"])
        summary.knownLabels = ["del": "Delhi"]
        #expect(summary.chosenLabels == ["München", "Delhi"] && summary.text == "2 selected")
        #expect(summary.label(of: "del") == "Delhi")
    }

    @Test("Groups are flattened for the trigger, and a label is found in any group")
    func groupedLabels() {
        let groups = [
            QeetrixComboboxGroup("Europe", items: [QeetrixComboboxItem("Zürich", value: 1)]),
            QeetrixComboboxGroup("Asia", items: [QeetrixComboboxItem("Mumbai", value: 2)]),
        ]
        let combobox = QeetrixCombobox("City", selection: .constant(2), groups: groups)
        #expect(combobox.sections.map(\.label) == ["Europe", "Asia"])
        let summary = QeetrixComboboxSummary(selection: combobox.selection, sections: combobox.sections, locale: Self.english)
        #expect(summary.text == "Mumbai")
        #expect(QeetrixComboboxGroup("Asia", items: [QeetrixComboboxItem<Int>]()).id == "Asia")
        #expect(QeetrixComboboxItem("Mumbai", value: 2).id == 2)
    }

    @Test("Only a server search remembers labels, so a choice it leaves out keeps its name")
    func rememberedLabels() {
        let local = QeetrixCombobox("City", selection: .constant("muc"), items: Self.cities)
        #expect(local.labelsToRemember.isEmpty)
        let remote = QeetrixCombobox("City", selection: .constant("muc"), items: Self.cities) { _ in }
        #expect(remote.labelsToRemember["muc"] == "München" && remote.labelsToRemember.count == Self.cities.count)
    }

    @Test("The built-in words are react's combobox messages")
    func strings() {
        #expect(QeetrixComboboxStrings.empty == "No matches")
        #expect(QeetrixComboboxStrings.loading == "Searching…")
        #expect(QeetrixComboboxStrings.selected(12, locale: Self.english) == "12 selected")
    }

    @Test("A 300 ms pause before a server search, as react's searchDelay")
    func delay() {
        #expect(QeetrixCombobox("City", selection: .constant("muc"), items: Self.cities).searchDelay == .milliseconds(300))
    }

    @Test("The trigger is the Select's field box, size.control.lg tall, Ember-framed while the sheet is open")
    func trigger() throws {
        func trigger(isOpen: Bool) -> some View {
            QeetrixComboboxTrigger(
                value: Text("München"), placeholder: nil, accessibilityValue: Text("München"), isOpen: isOpen, isReadOnly: false, action: {}
            )
            .frame(width: 200)
            .environment(\.colorScheme, .light)
        }
        let closed = try #require(Rendered(trigger(isOpen: false)))
        #expect(closed.height == 40)
        #expect(close(QeetrixTheme.light.resolve(.bgNeutralSubtle).bytes, closed.pixel(2, 20)))
        #expect(close(QeetrixTheme.light.resolve(.borderStrong).bytes, closed.pixel(100, 39)))
        let open = try #require(Rendered(trigger(isOpen: true)))
        #expect(close(QeetrixTheme.light.resolve(.borderFocus).bytes, open.pixel(0, 20)), "The 2 pt focus frame inside the box")
        #expect(close(QeetrixTheme.light.resolve(.borderFocus).bytes, open.pixel(100, 39)))
    }

    @Test("What the sheet draws keeps its contrast on the sheet's surface, in both schemes")
    func contrast() {
        // (foreground, background, minimum): the check (3:1, an icon) at rest and on a pressed row; the
        // status line, the pinned group labels and the option text (4.5:1).
        let pairs: [(QeetrixColor, QeetrixColor, Double)] = [
            (.iconBrand, .surfaceOverlay, 3), (.iconBrand, .bgNeutralSubtleHover, 3), (.textSubtle, .surfaceOverlay, 4.5),
            (.textSubtlest, .surfaceOverlay, 4.5), (.textDefault, .surfaceOverlay, 4.5),
        ]
        for theme in [QeetrixTheme.light, .dark] {
            for (foreground, background, minimum) in pairs {
                let ratio = QeetrixAccessibility.contrastRatio(theme.resolve(foreground), on: theme.resolve(background))
                #expect(ratio >= minimum, "\(foreground) on \(background), \(theme.colorScheme): \(ratio)")
            }
        }
    }

    @Test("Renders chosen, with a placeholder, with an error, read-only and disabled, light and dark")
    func renders() {
        for scheme in [ColorScheme.light, .dark] {
            let views: [AnyView] = [
                AnyView(QeetrixCombobox("City", selection: .constant("muc"), items: Self.cities)),
                AnyView(
                    QeetrixCombobox(
                        "City", selection: .constant(String?.none), items: Self.cities.map(Self.optional), placeholder: Text("e.g. Pune"),
                        error: "Choose a city")),
                AnyView(QeetrixCombobox("City", selection: .constant("muc"), items: Self.cities, isReadOnly: true)),
                AnyView(QeetrixCombobox("City", selection: .constant("muc"), items: Self.cities).disabled(true)),
                AnyView(QeetrixCombobox("Cities", selection: .constant(Set(["muc", "sao"])), items: Self.cities, isOptional: true)),
            ]
            for view in views {
                #expect(ImageRenderer(content: view.frame(width: 320).environment(\.colorScheme, scheme)).cgImage != nil)
            }
        }
    }

    @Test("The sheet renders its rows, groups, the empty state and the search in progress")
    func sheet() {
        let groups = [
            QeetrixComboboxSection(QeetrixComboboxGroup("Europe", items: Array(Self.cities.prefix(2)))),
            QeetrixComboboxSection(QeetrixComboboxGroup("Asia", items: Array(Self.cities.suffix(3)))),
        ]
        let sheets = [
            QeetrixComboboxSheet(
                title: Text("City"), sections: groups, selection: .single(.constant("muc")), searchPrompt: Text("e.g. Pune"),
                isLoading: false,
                messages: QeetrixComboboxMessages(), searchDelay: .milliseconds(300), onSearch: nil),
            QeetrixComboboxSheet(
                title: Text("Cities"), sections: groups, selection: .multiple(.constant(["muc", "hi"])), searchPrompt: nil,
                isLoading: false,
                messages: QeetrixComboboxMessages(), searchDelay: .milliseconds(300), onSearch: nil),
            QeetrixComboboxSheet(
                title: Text("City"), sections: groups, selection: .single(.constant("muc")), searchPrompt: nil, isLoading: false,
                messages: QeetrixComboboxMessages(), searchDelay: .milliseconds(300), onSearch: nil, query: "zzz"),
            QeetrixComboboxSheet(
                title: Text("City"), sections: groups, selection: .single(.constant("muc")), searchPrompt: nil, isLoading: true,
                messages: QeetrixComboboxMessages(), searchDelay: .milliseconds(300), onSearch: { _ in }),
        ]
        for sheet in sheets {
            #expect(ImageRenderer(content: sheet.frame(width: 390, height: 600)).cgImage != nil)
        }
    }

    static func optional(_ item: QeetrixComboboxItem<String>) -> QeetrixComboboxItem<String?> {
        QeetrixComboboxItem(item.label, value: Optional(item.value), description: item.description, isDisabled: item.isDisabled)
    }
}
