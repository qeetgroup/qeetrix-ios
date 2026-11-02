import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Search field")
struct SearchFieldTests {
    @Test("Typing waits for a pause; each keystroke restarts the wait")
    func typing() throws {
        var state = QeetrixSearchState()
        #expect(state.pending == nil)
        state.typed("As")
        let first = try #require(state.pending)
        #expect(first.query == "As")
        state.typed("Ash")
        let second = try #require(state.pending)
        #expect(second.query == "Ash" && second != first)
        #expect(state.pauseEnded(first) == nil, "A pause after a replaced keystroke searches nothing")
        #expect(state.pauseEnded(second) == "Ash")
        #expect(state.pending == nil)
        #expect(state.pauseEnded(second) == nil, "Once")
    }

    @Test("Typing the same text again is a new wait")
    func sameText() throws {
        var state = QeetrixSearchState()
        state.typed("Asha")
        let first = try #require(state.pending)
        state.typed("Asha")
        #expect(try #require(state.pending) != first)
    }

    @Test("The search key and clearing search at once, and drop the wait, so nothing asks twice")
    func searchNow() throws {
        var state = QeetrixSearchState()
        state.typed("Asha")
        let waiting = try #require(state.pending)
        #expect(state.searchNow("Asha") == "Asha")
        #expect(state.pending == nil)
        #expect(state.pauseEnded(waiting) == nil, "The pause that follows doesn't search again")
        #expect(state.searchNow("") == "")
    }

    @Test("Clear shows, and Escape clears, only while there is text in an editable field")
    func canClear() {
        #expect(QeetrixSearchState.canClear("Asha", isEnabled: true, isReadOnly: false))
        #expect(!QeetrixSearchState.canClear("", isEnabled: true, isReadOnly: false), "Empty: Escape goes through")
        #expect(!QeetrixSearchState.canClear("Asha", isEnabled: false, isReadOnly: false))
        #expect(!QeetrixSearchState.canClear("Asha", isEnabled: true, isReadOnly: true))
    }

    @Test("Named \"Search\" without a label; the clear button is \"Clear search\"")
    func strings() {
        #expect(QeetrixSearchFieldStrings.searchString == "Search")
        #expect(QeetrixSearchFieldStrings.clearString == "Clear search")
        let unlabelled = QeetrixSearchField(text: .constant(""))
        #expect(unlabelled.isLabelHidden)
        let labelled = QeetrixSearchField("Find a member", text: .constant(""), description: Text("Name or email."))
        #expect(!labelled.isLabelHidden && labelled.context.description != nil)
        #expect(QeetrixSearchField("Find a member", text: .constant(""), isLabelHidden: true).isLabelHidden)
    }

    @Test("A 300 ms pause by default")
    func delay() {
        #expect(QeetrixSearchField(text: .constant("")).searchDelay == .milliseconds(300))
        #expect(QeetrixSearchField(text: .constant(""), searchDelay: .seconds(1)).searchDelay == .seconds(1))
    }

    @Test("The field box: control.lg tall, the neutral fill and the strong bottom line")
    func box() throws {
        let field = QeetrixSearchField(text: .constant(""), prompt: Text("e.g. Asha"))
            .frame(width: 320)
            .environment(\.colorScheme, .light)
        let image = try #require(Rendered(field))
        #expect(image.height == 40)
        // In the padding, where the Mac draws no text-field bezel of its own.
        #expect(close(QeetrixTheme.light.resolve(.bgNeutralSubtle).bytes, image.pixel(2, 20)))
        #expect(close(QeetrixTheme.light.resolve(.bgNeutralSubtle).bytes, image.pixel(318, 20)), "4 pt at the end (search-field.css)")
        #expect(close(QeetrixTheme.light.resolve(.borderStrong).bytes, image.pixel(2, 39)))
    }

    @Test("Every state renders, light and dark")
    func renders() {
        for scheme in [ColorScheme.light, .dark] {
            let views: [AnyView] = [
                AnyView(QeetrixSearchField(text: .constant(""), prompt: Text("e.g. Asha"))),
                AnyView(QeetrixSearchField(text: .constant("Asha"))),
                AnyView(QeetrixSearchField("Find a member", text: .constant("Asha"), description: Text("Name or email."))),
                AnyView(QeetrixSearchField(text: .constant("Asha"), isReadOnly: true)),
                AnyView(QeetrixSearchField(text: .constant("Asha")).disabled(true)),
            ]
            for view in views {
                #expect(ImageRenderer(content: view.frame(width: 320).environment(\.colorScheme, scheme)).cgImage != nil)
            }
        }
    }

    @Test("The system search bar's modifier attaches")
    func searchable() {
        var searched: [String] = []
        let view = Text("Accounts")
            .qeetrixSearchable(text: .constant(""), prompt: Text("e.g. Asha")) { searched.append($0) }
        #expect(ImageRenderer(content: view).cgImage != nil)
        #expect(searched.isEmpty, "Nothing is searched until someone types")
    }
}
