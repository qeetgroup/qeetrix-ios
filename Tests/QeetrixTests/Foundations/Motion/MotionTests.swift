import SwiftUI
import Testing

@testable import Qeetrix

@Suite("Motion")
struct MotionTests {
    @Test("Reduce Motion switches to the reduced tokens, which mean no animation")
    func reduceMotion() {
        #expect(QeetrixMotion.reducedDuration.seconds == 0)
        #expect(QeetrixMotion.reducedEasing.isLinear)
        for easing in [QeetrixEasing.standard, .emphasized, .enter, .exit, .linear] {
            for duration in [QeetrixDuration.fast, .normal, .slow, .deliberate] {
                #expect(QeetrixMotion.animation(easing, duration, reduceMotion: true) == nil)
                #expect(QeetrixMotion.animation(easing, duration, reduceMotion: false) != nil)
            }
        }
    }

    @Test("A zero duration is no animation, not an instant one")
    func instant() {
        #expect(QeetrixDuration.instant.seconds == 0)
        #expect(QeetrixMotion.animation(.standard, .instant, reduceMotion: false) == nil)
    }

    @Test("Curves become the equivalent SwiftUI animations")
    func curves() {
        #expect(QeetrixEasing.standard == QeetrixEasing(0.4, 0, 0.2, 1))
        #expect(QeetrixEasing.standard.animation(duration: .normal) == .timingCurve(0.4, 0, 0.2, 1, duration: 0.2))
        #expect(QeetrixEasing.linear.animation(duration: .fast) == .linear(duration: 0.15))
    }

    @Test("Durations run in token order")
    func order() {
        #expect(
            [QeetrixDuration.instant, .fast, .normal, .slow, .deliberate]
                == [QeetrixDuration.instant, .fast, .normal, .slow, .deliberate].sorted())
    }
}
