import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Avatar")
struct AvatarTests {
    @Test(
        "Initials: the first grapheme of the first and last words, without a company's legal form",
        arguments: [
            ("Priya Sharma", "PS"),
            ("priya sharma", "PS"),
            ("Priya", "P"),
            ("  Mary  Ann   Smith ", "MS"),
            ("Kaveri Foods Private Limited", "KF"),
            ("Acme Pvt Ltd", "AC"),
            ("Acme Pvt. Ltd.", "AC"),
            ("Qeet Group LLP", "QG"),
            ("", ""),
            ("   ", ""),
            ("王小明", "王"),
            ("सीता राम", "सीरा"),  // vowel signs stay with their letter
            ("👩🏽‍💻 Dev", "👩🏽‍💻D"),
        ])
    func initials(name: String, expected: String) {
        #expect(QeetrixAvatar.initials(name) == expected)
    }

    @Test("Sizes: sm 24, md 32, lg 40, xl 48; shapes circle and square")
    func sizes() {
        #expect(QeetrixAvatarSize.allCases.map(\.points) == [24, 32, 40, 48])
        #expect(QeetrixAvatarShape.allCases.map(\.rawValue) == ["circle", "square"])
    }

    @Test("Initials: label.sm at sm and md, label.md at lg and xl, at a fixed size")
    func initialsType() {
        #expect(QeetrixAvatarSize.allCases.map { QeetrixAvatar.initialsType($0).tokens.size } == [12, 12, 14, 14])
        for size in QeetrixAvatarSize.allCases {
            #expect(QeetrixAvatar.initialsType(size).textStyle == nil, "Initials never outgrow the avatar")
            #expect(QeetrixAvatar.initialsType(size).tokens.weight == .medium)
        }
    }

    @Test("A square has the controls' 4 pt corners; a circle stays concentric when inset")
    func outline() {
        let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
        let square = QeetrixAvatarOutline(shape: .square)
        #expect(square.path(in: rect).contains(CGPoint(x: 4, y: 1)))
        #expect(!square.path(in: rect).contains(CGPoint(x: 0.2, y: 0.2)))
        let circle = QeetrixAvatarOutline(shape: .circle).inset(by: 1)
        #expect(circle.path(in: rect).boundingRect == rect.insetBy(dx: 1, dy: 1))
    }

    @Test("The fallback fill is bg.neutral.subtle-pressed")
    func fallback() throws {
        let image = try #require(
            Rendered(QeetrixAvatar(name: "Priya Sharma", size: .xl, shape: .square).environment(\.colorScheme, .light)))
        #expect(image.width == 48)
        #expect(close(QeetrixTheme.light.resolve(.bgNeutralSubtlePressed).bytes, image.pixel(3, 3)))
    }

    @Test("Avatars render with a photo, initials, decorative or not")
    func renders() {
        #expect(ImageRenderer(content: QeetrixAvatar(name: "Priya Sharma", image: Image(systemName: "person"))).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixAvatar(name: "Priya Sharma", isDecorative: true)).cgImage != nil)
    }
}
