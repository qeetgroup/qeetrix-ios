import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Switch")
struct SwitchTests {
    @Test("Tracks: 32 × 18.4 with a 16 pt thumb, 24 × 14 with a 12 pt thumb")
    func metrics() {
        let regular = QeetrixSwitchTrack.metrics(.default)
        #expect((regular.width, regular.height, regular.thumb) == (32, QeetrixSwitchTokens.thumbSize, 16))
        let small = QeetrixSwitchTrack.metrics(.sm)
        #expect((small.width, small.height, small.thumb) == (24, 14, 12))
    }

    @Test("The thumb travels the web's 100% − 2 pt: from one border to the other")
    func travel() {
        for size in QeetrixSwitchSize.allCases {
            let metrics = QeetrixSwitchTrack.metrics(size)
            let travel = metrics.width - 2 * QeetrixStroke.hairline - metrics.thumb
            #expect(travel == metrics.thumb - 2)
        }
    }

    @Test("Switches render on and off, as a view and through the style")
    func renders() {
        #expect(ImageRenderer(content: QeetrixSwitch("Email", isOn: .constant(true)).frame(width: 300)).cgImage != nil)
        #expect(
            ImageRenderer(content: Toggle("Wi-Fi", isOn: .constant(false)).toggleStyle(.qeetrixSwitch(size: .sm)).frame(width: 300)).cgImage
                != nil)
    }
}
