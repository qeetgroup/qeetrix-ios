import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Avatar")
struct AvatarTests {
    @Test(
        "Initials: the first character of the first and last words, upper-cased",
        arguments: [
            ("Asha Rao", "AR"),
            ("asha rao", "AR"),
            ("Priya", "P"),
            ("  Mary  Ann   Smith ", "MS"),
            ("", ""),
            ("   ", ""),
            ("王小明", "王"),
            ("👩🏽‍💻 Dev", "👩🏽‍💻D"),
        ])
    func initials(name: String, expected: String) {
        #expect(QeetrixAvatar.initials(name) == expected)
    }

    @Test("Sizes: 20, 24, 32, 40, 48")
    func sizes() {
        #expect(QeetrixAvatarSize.allCases.map(\.points) == [20, 24, 32, 40, 48])
    }

    @Test("Initials are medium, fixed-size: micro at xs and sm, then 14, 16, 18")
    func initialsType() {
        let micro = QeetrixTextRole.micro.tokens.size
        #expect(QeetrixAvatarSize.allCases.map { QeetrixAvatar.initialsType($0).tokens.size } == [micro, micro, 14, 16, 18])
        for size in QeetrixAvatarSize.allCases {
            #expect(QeetrixAvatar.initialsType(size).textStyle == nil, "Initials never outgrow the avatar")
            #expect(QeetrixAvatar.initialsType(size).tokens.weight == .medium)
        }
    }

    @Test("Badge marks: 6 pt with a 1 pt ring at xs, then 8, 10, 12, 14 with 2 pt rings")
    func badges() {
        #expect(QeetrixAvatarSize.allCases.map { QeetrixAvatar.badgeMetrics($0).size } == [6, 8, 10, 12, 14])
        #expect(QeetrixAvatarSize.allCases.map { QeetrixAvatar.badgeMetrics($0).ring } == [1, 2, 2, 2, 2])
    }

    @Test("A square's corners are 25% of its side, and stay concentric when inset")
    func outline() {
        let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
        let square = QeetrixAvatarOutline(shape: .square)
        #expect(square.path(in: rect).contains(CGPoint(x: 10, y: 1)))
        #expect(!square.path(in: rect).contains(CGPoint(x: 1, y: 1)))
        let circle = QeetrixAvatarOutline(shape: .circle).inset(by: 1)
        #expect(circle.path(in: rect).boundingRect == rect.insetBy(dx: 1, dy: 1))
    }
}
