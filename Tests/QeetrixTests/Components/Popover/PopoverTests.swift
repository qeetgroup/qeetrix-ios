import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Popover")
struct PopoverTests {
    @Test("popover.css: at most 360 pt wide, 16 pt padding")
    func width() throws {
        #expect(QeetrixPopoverSurface<EmptyView>.maximumWidth == 360)
        let text = String(repeating: "Admins can invite members. ", count: 12)
        let surface = QeetrixPopoverSurface(compactAdaptation: .popover) { Text(text) }
        let rendered = try #require(Rendered(surface))
        #expect(rendered.width <= 360)
        #expect(rendered.height > 100, "Long content wraps inside the 360 pt ideal width")
        let proposed = try #require(Rendered(surface.frame(width: 360)))
        #expect(proposed.height > 100, "Given a width, it wraps")
    }

    @Test("A title and description sit above the content")
    func header() throws {
        let plain = try #require(Rendered(QeetrixPopoverSurface(compactAdaptation: .popover) { Text("Body") }.frame(width: 300)))
        let titled = try #require(
            Rendered(
                QeetrixPopoverSurface(title: Text("Roles"), description: Text("Who can do what."), compactAdaptation: .popover) {
                    Text("Body")
                }
                .frame(width: 300)))
        #expect(titled.height > plain.height + 30)
    }

    @Test("The modifier attaches without presenting")
    func attaches() {
        let view = Text("Trigger").qeetrixPopover(isPresented: .constant(false), title: Text("Roles"), arrowEdge: .bottom) {
            Text("Content")
        }
        #expect(ImageRenderer(content: view).cgImage != nil)
    }
}
