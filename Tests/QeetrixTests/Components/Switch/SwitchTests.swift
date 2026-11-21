import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Switch")
struct SwitchTests {
    @Test("switch.css: a 32 × 18 track, a 12 pt thumb 2 pt in from the start, 16 pt when on")
    func metrics() {
        #expect((QeetrixSwitchTrack.width, QeetrixSwitchTrack.height, QeetrixSwitchTrack.thumb) == (32, 18, 12))
        #expect((QeetrixSwitchTrack.thumbInsetOff, QeetrixSwitchTrack.thumbInsetOn) == (2, 16))
        // Inside the 1 pt border, the thumb ends 2 pt from the end edge when on: 16 + 12 + 2 = 30.
        #expect(
            QeetrixSwitchTrack.thumbInsetOn + QeetrixSwitchTrack.thumb + QeetrixSwitchTrack.thumbInsetOff == QeetrixSwitchTrack.width - 2)
    }

    private func track(on: Bool, hovered: Bool = false, enabled: Bool = true, invalid: Bool = false) -> QeetrixSwitchTrack {
        QeetrixSwitchTrack(isOn: on, isHovered: hovered, isEnabled: enabled, isInvalid: invalid)
    }

    @Test("Off: bg.input, a strong edge, the graphite thumb; on: Ember track and edge, the white on-brand thumb")
    func colours() {
        #expect((track(on: false).track, track(on: false).edge, track(on: false).thumbColor) == (.bgInput, .borderStrong, .iconSubtle))
        #expect(track(on: false, hovered: true).edge == .borderStrongHover)
        #expect(track(on: false, invalid: true).edge == .borderDanger)
        #expect((track(on: true).track, track(on: true).edge, track(on: true).thumbColor) == (.bgBrandBold, .bgBrandBold, .iconOnBrand))
        #expect(track(on: true, hovered: true).track == .bgBrandBoldHover)
        // An invalid switch keeps the danger edge on and hovered, round the Ember track.
        for (on, hovered) in [(false, true), (true, false), (true, true)] {
            #expect(track(on: on, hovered: hovered, invalid: true).edge == .borderDanger, "on \(on), hovered \(hovered)")
        }
        #expect(track(on: true, hovered: true, invalid: true).track == .bgBrandBoldHover)
        #expect(track(on: true, enabled: false, invalid: true).edge == .borderDisabled)
        #expect((track(on: true, enabled: false).track, track(on: true, enabled: false).thumbColor) == (.bgDisabled, .iconDisabled))
    }

    @Test("The thumb sits at the start when off and the end when on, mirrored in right-to-left")
    func thumb() throws {
        func thumbColumn(on: Bool, _ direction: LayoutDirection = .leftToRight) throws -> Int {
            let image = try #require(Rendered(track(on: on).environment(\.colorScheme, .light).environment(\.layoutDirection, direction)))
            let thumb = QeetrixTheme.light.resolve(on ? .iconOnBrand : .iconSubtle).bytes
            return (0..<image.width).first { close(thumb, image.pixel($0, 9), tolerance: 6) } ?? -1
        }
        #expect(try thumbColumn(on: false) == 3)
        #expect(try thumbColumn(on: true) == 17)
    }

    @Test("The on thumb is white in both schemes, as the checkbox's tick")
    func thumbIsWhite() {
        for theme in [QeetrixTheme.light, .dark] {
            let thumb = theme.resolve(track(on: true).thumbColor)
            #expect(thumb.red > 0.99 && thumb.green > 0.99 && thumb.blue > 0.99, "\(theme.colorScheme)")
        }
    }

    @Test("Switches render on and off, described, as a view and through the style")
    func renders() {
        #expect(
            ImageRenderer(content: QeetrixSwitch("Auto-renew", isOn: .constant(true), description: Text("Renews yearly")).frame(width: 300))
                .cgImage != nil)
        #expect(
            ImageRenderer(content: Toggle("Wi-Fi", isOn: .constant(false)).toggleStyle(.qeetrixSwitch).frame(width: 300)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixSwitch("Auto-renew", isOn: .constant(true)).disabled(true).frame(width: 300)).cgImage != nil)
    }

    @Test("A bare switch is the track's 32 × 18 pt at any width offered, and takes a tap 44 pt round it")
    func bareSize() throws {
        func size(_ view: some View) throws -> (Int, Int) {
            let renderer = ImageRenderer(content: view)
            renderer.proposedSize = ProposedViewSize(width: 300, height: 100)
            renderer.scale = 1
            let image = try #require(renderer.cgImage)
            return (image.width, image.height)
        }
        #expect(try size(QeetrixSwitch(isOn: .constant(true), accessibilityLabel: Text("Unlock with Face ID"))) == (32, 18))
        #expect(try size(QeetrixSwitch(isOn: .constant(false), accessibilityLabel: Text("Unlock with Face ID")).disabled(true)) == (32, 18))
        // The labelled switch is a row: it takes the width it's offered.
        #expect(try size(QeetrixSwitch("Unlock with Face ID", isOn: .constant(true))).0 == 300)
        // The hit area spills 6 pt past each side and 13 pt above and below, without moving layout.
        let track = CGRect(x: 0, y: 0, width: QeetrixSwitchTrack.width, height: QeetrixSwitchTrack.height)
        #expect(QeetrixHitArea().path(in: track).boundingRect == CGRect(x: -6, y: -13, width: 44, height: 44))
    }

    #if os(macOS)
        @Test("A bare switch is read as the system's switch, named by its accessibility label, with its state")
        func bareAccessibility() {
            func bare(_ isOn: Bool) -> some View { QeetrixSwitch(isOn: .constant(isOn), accessibilityLabel: Text("Unlock with Face ID")) }
            let on = ListsAccessibilityTree.elements(of: bare(true))
            #expect(on.map(\.text) == ["Unlock with Face ID"], "\(on)")
            #expect(on.map(\.value) == ["1"])
            // The Mac draws the representation as its checkbox; iOS reads the same Toggle as a switch.
            #expect(on.map(\.role) == ["AXCheckBox"])
            let off = ListsAccessibilityTree.elements(of: bare(false))
            #expect(off.map(\.value) == ["0"])
        }
    #endif
}
