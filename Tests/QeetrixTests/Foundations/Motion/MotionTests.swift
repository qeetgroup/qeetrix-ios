import SwiftUI
import Testing

@testable import Qeetrix

@Suite("Motion")
struct MotionTests {
    @Test("Reduce Motion turns every duration to 0 ms: no animation")
    func reduceMotion() {
        #expect(QeetrixMotion.reducedDuration.seconds == 0)
        for easing in [QeetrixEasing.standard, .emphasized, .enter, .exit, .linear] {
            for duration in [QeetrixDuration.fast, .normal, .slow, .slower] {
                #expect(QeetrixMotion.animation(easing, duration, reduceMotion: true) == nil)
                #expect(QeetrixMotion.animation(easing, duration, reduceMotion: false) != nil)
            }
        }
        #expect(QeetrixMotion.animation(.snappy, reduceMotion: true) == nil)
        #expect(QeetrixMotion.animation(.gentle, reduceMotion: false) != nil)
    }

    @Test("A zero duration is no animation, not an instant one")
    func instant() {
        #expect(QeetrixDuration.instant.seconds == 0)
        #expect(QeetrixMotion.animation(.standard, .instant, reduceMotion: false) == nil)
    }

    @Test("Durations are the design rules' 100, 200, 300, 400 ms, in order")
    func durations() {
        #expect([QeetrixDuration.fast, .normal, .slow, .slower].map(\.seconds) == [0.1, 0.2, 0.3, 0.4])
        #expect(
            [QeetrixDuration.instant, .fast, .normal, .slow, .slower] == [QeetrixDuration.instant, .fast, .normal, .slow, .slower].sorted())
    }

    @Test("Curves become the equivalent SwiftUI animations")
    func curves() {
        #expect(QeetrixEasing.standard.animation(duration: .normal) == .timingCurve(0.65, 0, 0.35, 1, duration: 0.2))
        #expect(QeetrixEasing.enter == QeetrixEasing(0.25, 1, 0.5, 1))
        #expect(QeetrixEasing.exit == QeetrixEasing(0.32, 0, 0.67, 0))
        #expect(QeetrixEasing.linear.isLinear)
        #expect(QeetrixEasing.linear.animation(duration: .fast) == .linear(duration: 0.1))
    }

    @Test("Springs: mass 1, damping from the ratio")
    func springs() {
        #expect(QeetrixSpring.snappy == QeetrixSpring(stiffness: 400, dampingRatio: 0.9))
        #expect(QeetrixSpring.gentle == QeetrixSpring(stiffness: 200, dampingRatio: 1))
        #expect(QeetrixSpring.gentle.animation == .interpolatingSpring(mass: 1, stiffness: 200, damping: 2 * 200.0.squareRoot()))
    }
}
