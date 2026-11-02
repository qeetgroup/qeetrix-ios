import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Sheet")
struct SheetTests {
    @Test("Intents are the Dialog's: Ember, danger, and the warning icon colour for the 3 pt line")
    func intents() {
        #expect(QeetrixDialogIntent.allCases.map(\.rawValue) == ["standard", "danger", "warning"])
        #expect(QeetrixDialogIntent.allCases.map(\.color) == [.borderBrand, .borderDanger, .iconWarning])
    }

    @Test("An intent draws the 3 pt line across the top")
    func intentLine() throws {
        let sheet = QeetrixSheetContent("Revoke this API key?", intent: .danger) {
            Text("Apps using it stop working.")
        } actions: {
            QeetrixButton("Revoke key", tone: .danger) {}
        }
        let image = try #require(Rendered(sheet.frame(width: 390, height: 400).environment(\.colorScheme, .light)))
        #expect(close(QeetrixTheme.light.resolve(.borderDanger).bytes, image.pixel(195, 1)))
        #expect(close(QeetrixTheme.light.resolve(.surfaceOverlay).bytes, image.pixel(195, 5)))
    }

    @Test("The layout renders with and without a description, dismissible or not, light and dark")
    func renders() {
        for scheme in [ColorScheme.light, .dark] {
            let full = QeetrixSheetContent("Edit address", description: Text("Used on every invoice.")) {
                Text("Content")
            } actions: {
                QeetrixButton("Cancel", variant: .ghost, size: .lg) {}
                QeetrixButton("Save", size: .lg) {}
            }
            let bare = QeetrixSheetContent("Unsaved changes", isDismissible: false, onClose: {}) {
                Text("Content")
            } actions: {
                EmptyView()
            }
            #expect(ImageRenderer(content: full.frame(width: 390, height: 500).environment(\.colorScheme, scheme)).cgImage != nil)
            #expect(ImageRenderer(content: bare.frame(width: 390, height: 300).environment(\.colorScheme, scheme)).cgImage != nil)
        }
    }

    @Test("Close runs onClose when given")
    func onClose() {
        var closed = 0
        let sheet = QeetrixSheetContent("Edit", onClose: { closed += 1 }) {
            EmptyView()
        } actions: {
            EmptyView()
        }
        sheet.onClose?()
        #expect(closed == 1)
        #expect(sheet.isDismissible)
        #expect(sheet.intent == nil, "Without an intent it is the drawer: no line")
    }

    @Test("The modifiers attach without presenting")
    func attaches() {
        struct Item: Identifiable { let id: Int }
        let view = Text("Content")
            .qeetrixSheet(isPresented: .constant(false), detents: [.medium, .large]) { Text("Sheet") }
            .qeetrixSheet(item: .constant(Item?.none)) { item in Text("\(item.id)") }
        #expect(ImageRenderer(content: view).cgImage != nil)
    }
}
