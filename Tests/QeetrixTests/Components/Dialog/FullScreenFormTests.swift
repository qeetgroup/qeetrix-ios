import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Full-screen form")
struct FullScreenFormTests {
    private let save = QeetrixScreenAction("Save") {}

    @Test("Close dismisses without changes, asks first with them, and gives way to onClose")
    func closing() {
        #expect(QeetrixFullScreenFormMetrics.closing(hasChanges: false, hasOnClose: false) == .dismiss)
        #expect(QeetrixFullScreenFormMetrics.closing(hasChanges: true, hasOnClose: false) == .confirmDiscard)
        #expect(QeetrixFullScreenFormMetrics.closing(hasChanges: true, hasOnClose: true) == .callOnClose)
        #expect(QeetrixFullScreenFormMetrics.closing(hasChanges: false, hasOnClose: true) == .callOnClose)
    }

    @Test("Over the whole screen at compact width, a form sheet at regular width")
    func presentation() {
        #expect(QeetrixFullScreenFormStyle(.compact) == .fullScreen)
        #expect(QeetrixFullScreenFormStyle(nil) == .fullScreen)
        #expect(QeetrixFullScreenFormStyle(.regular) == .formSheet)
    }

    @Test("The phone's 16 pt gutter or the Dialog's 24; the app chrome's height; Close's icon on the gutter")
    func metrics() {
        #expect(QeetrixFullScreenFormMetrics.gutter(isCompact: true) == 16)
        #expect(QeetrixFullScreenFormMetrics.gutter(isCompact: false) == 24)
        #expect(QeetrixFullScreenFormMetrics.barHeight(.compact) == 48)
        #expect(QeetrixFullScreenFormMetrics.barHeight(.default) == 56)
        #expect(QeetrixFullScreenFormMetrics.barHeight(.comfortable) == 60)
        // A 32 pt md icon button round a 16 pt icon at the default density.
        #expect(QeetrixFullScreenFormMetrics.closeInset(.default) == 8)
        #expect(QeetrixFullScreenFormMetrics.closeInset(.compact) == 6)
    }

    @Test("The bar: one row while the title fits between the buttons, else the title on its own line")
    func bar() throws {
        #expect(QeetrixFullScreenFormBarLayout.fitsOneRow(width: 358, close: 32, title: 120, confirm: 60, spacing: 8))
        #expect(QeetrixFullScreenFormBarLayout.fitsOneRow(width: 358, close: 32, title: 250, confirm: 60, spacing: 8))
        #expect(!QeetrixFullScreenFormBarLayout.fitsOneRow(width: 358, close: 32, title: 251, confirm: 60, spacing: 8))
        func height(_ title: String) throws -> Int {
            let bar = QeetrixFullScreenFormBar(title: Text(title), confirm: save, gutter: 16, discard: .constant(nil), close: {})
                .frame(width: 390)
                .environment(\.colorScheme, .light)
            return try #require(Rendered(bar)).height
        }
        // The 3 pt line, the 56 pt bar, the 1 pt rule.
        #expect(try height("New contact") == 3 + 56 + 1)
        #expect(try height("Edit the billing address used on every invoice") > 3 + 56 + 1, "The title's own line")
    }

    @Test("The built-in strings, in English until translated")
    func strings() {
        #expect(QeetrixFullScreenFormStrings.discardTitleString == "Discard your changes?")
        #expect(QeetrixFullScreenFormStrings.discardString == "Discard changes")
        #expect(QeetrixFullScreenFormStrings.keepEditingString == "Keep editing")
    }

    @Test("The Dialog's 3 pt Ember line across the top, on the overlay surface")
    func intentLine() throws {
        let form = QeetrixFullScreenForm("New contact", confirm: save) {
            QeetrixTextField("Name", text: .constant(""))
        }
        let image = try #require(Rendered(form.frame(width: 390, height: 400).environment(\.colorScheme, .light)))
        #expect(close(QeetrixTheme.light.resolve(.borderBrand).bytes, image.pixel(195, 1)))
        #expect(close(QeetrixTheme.light.resolve(.surfaceOverlay).bytes, image.pixel(195, 6)))
        let dark = try #require(Rendered(form.frame(width: 390, height: 400).environment(\.colorScheme, .dark)))
        #expect(close(QeetrixTheme.dark.resolve(.borderBrand).bytes, dark.pixel(195, 1)))
        #expect(close(QeetrixTheme.dark.resolve(.surfaceOverlay).bytes, dark.pixel(195, 6)))
    }

    @Test("The form keeps its settings: the title, the action, the changes flag and the replacements")
    func settings() {
        var closed = 0
        let form = QeetrixFullScreenForm(
            "Edit address", confirm: QeetrixScreenAction("Save", isLoading: true) {}, hasChanges: true,
            discardTitle: Text("Discard this address?"), onClose: { closed += 1 }
        ) {
            EmptyView()
        }
        #expect(form.hasChanges && form.confirm.isLoading && form.discardTitle != nil)
        form.onClose?()
        #expect(closed == 1)
        let plain = QeetrixFullScreenForm("New contact", confirm: save) { EmptyView() }
        #expect(!plain.hasChanges && plain.onClose == nil && plain.discardTitle == nil)
    }

    @Test("It renders, light and dark, compact and regular, a long title on its own line")
    func renders() {
        for scheme in [ColorScheme.light, .dark] {
            for sizeClass in [UserInterfaceSizeClass.compact, .regular] {
                let form = QeetrixFullScreenForm(
                    "Edit the billing address used on every invoice", confirm: QeetrixScreenAction("Save", isDisabled: true) {},
                    hasChanges: true
                ) {
                    QeetrixTextField("Street", text: .constant("12 MG Road"))
                    QeetrixTextField("City", text: .constant("Bengaluru"))
                }
                .frame(width: sizeClass == .compact ? 390 : 540, height: 500)
                .environment(\.colorScheme, scheme)
                .environment(\.horizontalSizeClass, sizeClass)
                #expect(ImageRenderer(content: form).cgImage != nil)
            }
        }
    }

    @Test("The modifiers attach without presenting")
    func attaches() {
        struct Contact: Identifiable { let id: Int }
        let view = Text("Contacts")
            .qeetrixFullScreenForm(isPresented: .constant(false)) {
                QeetrixFullScreenForm("New contact", confirm: QeetrixScreenAction("Save") {}) { EmptyView() }
            }
            .qeetrixFullScreenForm(item: .constant(Contact?.none)) { contact in
                QeetrixFullScreenForm("Edit contact \(contact.id)", confirm: QeetrixScreenAction("Save") {}) { EmptyView() }
            }
        #expect(ImageRenderer(content: view).cgImage != nil)
    }
}
