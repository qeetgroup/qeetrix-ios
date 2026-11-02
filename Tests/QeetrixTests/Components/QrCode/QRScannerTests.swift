import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("QR scanner")
struct QRScannerTests {
    @Test("States: scanning, the camera's two permission states, and no camera")
    func states() {
        #expect(QeetrixQRScannerState.allCases.map(\.rawValue) == ["scanning", "notDetermined", "denied", "unavailable"])
    }

    @Test("The target is 70% of the width, at most 280 pt, and gives way to large text")
    func target() {
        #expect(QeetrixQRScannerLayout.targetSide(in: CGSize(width: 390, height: 700), reserved: 200) == 273)
        #expect(QeetrixQRScannerLayout.targetSide(in: CGSize(width: 820, height: 1000), reserved: 200) == 280)
        #expect(QeetrixQRScannerLayout.targetSide(in: CGSize(width: 390, height: 300), reserved: 200) == 100)
        #expect(QeetrixQRScannerLayout.targetSide(in: CGSize(width: 390, height: 100), reserved: 200) == 0)
    }

    @Test("Corners: 3 pt right angles, 24 pt long, just outside the hole")
    func corners() {
        #expect(QeetrixQRScannerScrim.cornerWidth == QeetrixBorderWidth.accent && QeetrixQRScannerScrim.cornerLength == 24)
        let target = CGRect(x: 100, y: 100, width: 200, height: 200)
        let bounds = QeetrixQRScannerScrim.corners(around: target).boundingRect
        #expect(bounds == target.insetBy(dx: -1.5, dy: -1.5))
        let stroke = QeetrixQRScannerScrim.corners(around: target).strokedPath(StrokeStyle(lineWidth: 3)).boundingRect
        #expect(stroke == target.insetBy(dx: -3, dy: -3), "The line ends at the hole's edge")
    }

    @Test("Over a white scene under the dark scrim the guidance keeps 4.5:1, the corners and the torch 3:1")
    func contrast() {
        let dark = QeetrixTheme.dark
        let scrim = dark.resolve(.overlayScrim)
        for scene in [Color.Resolved(red: 1, green: 1, blue: 1), Color.Resolved(red: 0, green: 0, blue: 0)] {
            let alpha = scrim.opacity
            let shaded = Color.Resolved(
                red: scrim.red * alpha + scene.red * (1 - alpha), green: scrim.green * alpha + scene.green * (1 - alpha),
                blue: scrim.blue * alpha + scene.blue * (1 - alpha))
            #expect(QeetrixAccessibility.contrastRatio(dark.resolve(.textDefault), on: shaded) >= 4.5)
            #expect(QeetrixAccessibility.contrastRatio(dark.resolve(.iconDefault), on: shaded) >= 3, "The corners")
            #expect(QeetrixAccessibility.contrastRatio(dark.resolve(.textSubtle), on: shaded) >= 3, "The torch, off")
        }
        #expect(QeetrixAccessibility.contrastRatio(dark.resolve(.textInverse), on: dark.resolve(.bgNeutralBold)) >= 4.5)
        let lightScrim = QeetrixTheme.light.resolve(.overlayScrim)
        #expect(lightScrim.opacity < scrim.opacity, "Why the viewfinder is dark: light's scrim is lighter")
    }

    @Test("The torch: no fill and the outline while off, the neutral bold fill and inverse icon while on")
    func torch() {
        let off = QeetrixQRScannerTorchButtonStyle.colors(isOn: false, isPressed: false, isEnabled: true)
        #expect(off.fill == nil && off.icon == .textSubtle)
        let on = QeetrixQRScannerTorchButtonStyle.colors(isOn: true, isPressed: false, isEnabled: true)
        #expect(on.fill == .bgNeutralBold && on.icon == .textInverse)
        #expect(QeetrixQRScannerTorchButtonStyle.colors(isOn: true, isPressed: true, isEnabled: true).fill == .bgNeutralBoldPressed)
        #expect(QeetrixQRScannerTorchButtonStyle.colors(isOn: false, isPressed: true, isEnabled: true).fill == .bgNeutralSubtlePressed)
        #expect(QeetrixQRScannerTorchButtonStyle.colors(isOn: true, isPressed: false, isEnabled: false).icon == .iconDisabled)
        #expect(QeetrixIconName.flashlight.hasDrawing(.sharp, .filled) && QeetrixIconName.flashlightOff.hasDrawing(.sharp, .outline))
    }

    @Test("Scanning: the preview shows through the target and is darkened round it, the same in right to left")
    func viewfinder() throws {
        let dark = QeetrixTheme.dark
        let scrim = dark.resolve(.overlayScrim)
        let shaded = (
            r: Int(((scrim.red * scrim.opacity + (1 - scrim.opacity)) * 255).rounded()),
            g: Int(((scrim.green * scrim.opacity + (1 - scrim.opacity)) * 255).rounded()),
            b: Int(((scrim.blue * scrim.opacity + (1 - scrim.opacity)) * 255).rounded())
        )
        for direction in [LayoutDirection.leftToRight, .rightToLeft] {
            let scanner = QeetrixQRScanner(state: .scanning, isTorchOn: .constant(false), onContinue: {}) { Color.white }
                .frame(width: 390, height: 640)
                .environment(\.layoutDirection, direction)
            let image = try #require(Rendered(scanner))
            #expect(close((255, 255, 255), image.pixel(195, 320)), "The target's centre, \(direction)")
            #expect(close((255, 255, 255), image.pixel(80, 320)), "Inside the target's start edge, \(direction)")
            #expect(close(shaded, image.pixel(10, 320), tolerance: 4), "Beside the target, \(direction)")
            #expect(close(shaded, image.pixel(380, 630), tolerance: 4), "A corner of the viewfinder, \(direction)")
        }
    }

    @Test("Every state renders, with and without the torch and the typed-key fallback, and the app's words")
    func renders() {
        for state in QeetrixQRScannerState.allCases {
            let scanner = QeetrixQRScanner(state: state, isTorchOn: .constant(true), onContinue: {}, onTypeKey: {}) { Color.gray }
            #expect(ImageRenderer(content: scanner.frame(width: 390, height: 640)).cgImage != nil)
            let bare = QeetrixQRScanner(state: state, onContinue: {}) { Color.gray }
            #expect(ImageRenderer(content: bare.frame(width: 390, height: 640)).cgImage != nil)
        }
        let messages = QeetrixQRScannerMessages(guidance: Text("Point the camera at the QR code on the Qeet ID setup page"))
        let scanner = QeetrixQRScanner(state: .scanning, messages: messages, onContinue: {}) { Color.black }
        #expect(ImageRenderer(content: scanner.frame(height: 640)).cgImage != nil)
    }

    @Test("Built-in words are English until the app's replace them")
    func strings() {
        func string(_ resource: LocalizedStringResource) -> String {
            var resource = resource
            resource.locale = Locale(identifier: "en")
            return String(localized: resource)
        }
        #expect(string(QeetrixQRScannerStrings.guidance) == "Point the camera at the QR code")
        #expect(string(QeetrixQRScannerStrings.torch) == "Torch")
        #expect(string(QeetrixQRScannerStrings.typeKey) == "Type the key instead")
        #expect(string(QeetrixQRScannerStrings.deniedTitle) == "Camera access is off")
        #expect(string(QeetrixQRScannerStrings.unavailableTitle) == "No camera")
    }
}
