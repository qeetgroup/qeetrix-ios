import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Steps")
struct StepsTests {
    static let four = [QeetrixStep("Account"), QeetrixStep("Verify phone"), QeetrixStep("Passkey"), QeetrixStep("Done")]

    @Test("Statuses and orientations are @qeetrix/react's")
    func names() {
        #expect(QeetrixStepStatus.allCases.map(\.rawValue) == ["done", "current", "upcoming", "failed", "attention"])
        #expect(QeetrixStepsOrientation.allCases.map(\.rawValue) == ["horizontal", "vertical"])
    }

    @Test("Done before current, current at it, upcoming after; a status overrides")
    func states() {
        let steps = QeetrixSteps(Self.four, current: 1)
        #expect(Self.four.indices.map(steps.state) == [.done, .current, .upcoming, .upcoming])
        #expect(QeetrixSteps(Self.four, current: 4).state(3) == .done, "Every step done")
        let checked = QeetrixSteps([QeetrixStep("Connect"), QeetrixStep("Verify", status: .failed), QeetrixStep("Test")], current: 2)
        #expect([0, 1, 2].map(checked.state) == [.done, .failed, .current])
    }

    @Test("VoiceOver reads each step's position and state, in the web's words")
    func spoken() {
        let steps = QeetrixSteps(Self.four, current: 1)
        #expect(steps.accessibilityValue(0) == "Step 1 of 4, Completed")
        #expect(steps.accessibilityValue(1) == "Step 2 of 4, Current step")
        #expect(steps.accessibilityValue(3) == "Step 4 of 4, Not started")
        #expect(QeetrixStepStatus.failed.spokenName == "Failed")
        #expect(QeetrixStepStatus.attention.spokenName == "Needs attention")
        #expect(QeetrixStepsMetrics.position(2, of: 4) == "Step 2 of 4")
    }

    @Test("The compact form shows the current step, or the last once all are done, over the share done")
    func compact() {
        #expect(QeetrixSteps(Self.four, current: 1).shownIndex == 1)
        #expect(QeetrixSteps(Self.four, current: 4).shownIndex == 3)
        #expect(QeetrixSteps(Self.four, current: -2).shownIndex == 0)
        #expect(QeetrixSteps(Self.four, current: 1).fractionDone == 0.25)
        #expect(QeetrixSteps(Self.four, current: 4).fractionDone == 1)
        #expect(QeetrixSteps([], current: 0).fractionDone == 0)
    }

    @Test("Markers: done Ember with a tick, current an Ember ring, upcoming a grey ring, failed and attention filled")
    func markers() {
        let done = QeetrixStepsMetrics.marker(.done)
        #expect(done.fill == .bgBrandBold && done.ring == nil && done.ink == .textOnBrand)
        let current = QeetrixStepsMetrics.marker(.current)
        #expect(current.fill == nil && current.ring?.0 == .borderBrand && current.ring?.1 == 2 && current.ink == .textBrand)
        let upcoming = QeetrixStepsMetrics.marker(.upcoming)
        #expect(upcoming.ring?.0 == .borderStrong && upcoming.ring?.1 == 1 && upcoming.ink == .textSubtle)
        #expect(QeetrixStepsMetrics.marker(.failed).fill == .bgDangerBold && QeetrixStepsMetrics.marker(.failed).ink == .textOnBold)
        #expect(
            QeetrixStepsMetrics.marker(.attention).fill == .bgWarningBold && QeetrixStepsMetrics.marker(.attention).ink == .textOnWarning)
        #expect(QeetrixStepsMetrics.connector(after: .done) == .borderBrand)
        #expect(QeetrixStepsMetrics.connector(after: .current) == .borderSubtle)
        #expect(QeetrixStepsMetrics.markerSize == 24)
    }

    @Test("Only done steps are buttons, and only with onStepSelect")
    func selection() {
        var chosen: [Int] = []
        let steps = QeetrixSteps(Self.four, current: 2) { chosen.append($0) }
        #expect(Self.four.indices.map(steps.isSelectable) == [true, true, false, false])
        #expect(!QeetrixSteps(Self.four, current: 2).isSelectable(0))
        steps.onStepSelect?(1)
        #expect(chosen == [1])
    }

    @Test("Equal columns; the ideal width is every column at the widest one's")
    func columns() throws {
        let layout = QeetrixStepsColumns {
            Color.blue.frame(width: 30, height: 20)
            Color.red.frame(width: 50, height: 10)
        }
        let ideal = try #require(Rendered(layout.fixedSize()))
        #expect(ideal.width == 100 && ideal.height == 20)
        let laid = try #require(Rendered(layout.frame(width: 200)))
        #expect(laid.pixel(10, 5).b > 200, "Each column starts at its share of the width")
        #expect(laid.pixel(110, 5).r > 200)
        #expect(laid.pixel(60, 5).a == 0)
    }

    @Test("Across the screen where the labels fit; the compact form with its bar where they don't")
    func fits() throws {
        func steps(_ labels: [String], width: CGFloat) throws -> Rendered {
            let view = QeetrixSteps(labels.map { QeetrixStep($0) }, current: 1)
            return try #require(Rendered(view.frame(width: width).background(Color.white).environment(\.colorScheme, .light)))
        }
        let brand = QeetrixTheme.light.resolve(.bgBrandBold).bytes
        // Four short labels in 358 pt: the first marker, done, is filled Ember at its column's centre.
        let across = try steps(["Account", "Phone", "Passkey", "Done"], width: 358)
        #expect(close(brand, across.pixel(358 / 8 - 9, 3)), "The done marker's corner, clear of its tick")
        // Long labels don't fit on one line in a quarter of 300 pt: the compact form, whose bar is a quarter
        // Ember along its bottom 4 pt.
        let compact = try steps(["Create your account", "Verify your phone number", "Add a passkey", "Finish"], width: 300)
        #expect(close(brand, compact.pixel(30, compact.height - 2)))
        #expect(!close(brand, compact.pixel(150, compact.height - 2)))
    }

    @Test("Vertical: a line down from each marker but the last; labels never truncate")
    func vertical() throws {
        let view = QeetrixSteps(
            [QeetrixStep("Connect", description: "Okta, as SAML"), QeetrixStep("Map attributes")], current: 1, orientation: .vertical)
        let image = try #require(Rendered(view.frame(width: 300).background(Color.white).environment(\.colorScheme, .light)))
        // The first row: its 20 pt label and 16 pt description, then 16 pt; the second, a 24 pt marker.
        #expect(abs(image.height - (2 + 20 + 16 + 16 + 24)) <= 3, "A point per text block on iOS: \(image.height)")
        // The done step's line is Ember: 11.5–12.5 pt from the start, from 4 pt under its marker.
        let brand = QeetrixTheme.light.resolve(.borderBrand).bytes
        #expect(close(brand, image.pixel(11, 40), tolerance: 60) || close(brand, image.pixel(12, 40), tolerance: 60))
        #expect(ImageRenderer(content: view.frame(width: 300).environment(\.dynamicTypeSize, .accessibility3)).cgImage != nil)
        // A label line taller than the marker moves the marker down to its centre.
        #expect(QeetrixStepsMetrics.offsets(marker: 24, line: 20) == (0, 2))
        #expect(QeetrixStepsMetrics.offsets(marker: 40, line: 60) == (10, 0))
    }
}
