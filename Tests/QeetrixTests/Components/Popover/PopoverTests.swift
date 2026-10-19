import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Popover")
struct PopoverTests {
    @Test("The surface is w-72 wide at its ideal size, with p-4")
    func idealWidth() throws {
        let surface = QeetrixPopoverSurface(compactAdaptation: .automatic) { Text("Hi") }.fixedSize()
        let rendered = try #require(Rendered(surface))
        #expect(rendered.width == 288)
    }

    @Test("Long content wraps inside the width")
    func wraps() throws {
        let text = String(repeating: "Admins can invite members. ", count: 8)
        let surface = QeetrixPopoverSurface(compactAdaptation: .popover) { Text(text) }.frame(width: 288)
        let rendered = try #require(Rendered(surface))
        #expect(rendered.width == 288)
        #expect(rendered.height > 100)
    }

    @Test("Tokens from component.popover")
    func tokens() {
        #expect(QeetrixPopoverTokens.background == QeetrixComponentColor(.surfaceOverlay))
        #expect(QeetrixPopoverTokens.foreground == QeetrixComponentColor(.textPrimary))
        #expect(QeetrixPopoverTokens.elevation == .overlay)
    }

    @Test("The modifier attaches without presenting")
    func attaches() {
        let view = Text("Trigger").qeetrixPopover(isPresented: .constant(false), arrowEdge: .bottom) { Text("Content") }
        #expect(ImageRenderer(content: view).cgImage != nil)
    }
}
