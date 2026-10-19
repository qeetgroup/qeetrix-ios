import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Sheet")
struct SheetTests {
    @Test("Title in the heading role, body text-sm, surface from component.dialog")
    func metrics() {
        #expect(QeetrixSheetMetrics.titleType == QeetrixTypeSpec(.heading))
        #expect(QeetrixSheetMetrics.bodyType.tokens.size == 14)
        #expect(QeetrixDialogTokens.background == QeetrixComponentColor(.surfaceOverlay))
        #expect(QeetrixDialogTokens.corner == QeetrixCorner.overlay)
    }

    @Test("The layout renders with and without a description, light and dark")
    func renders() {
        for scheme in [ColorScheme.light, .dark] {
            let full = QeetrixSheetContent("Edit profile", description: Text("Your team sees these details.")) {
                Text("Content")
            } actions: {
                QeetrixButton("Cancel", variant: .outline) {}
                QeetrixButton("Save") {}
            }
            let bare = QeetrixSheetContent("Filters", onClose: {}) {
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
        #expect(
            QeetrixSheetContent("Edit") {
                EmptyView()
            } actions: {
                EmptyView()
            }.onClose == nil)
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
