import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Avatar group")
struct AvatarGroupTests {
    private let english = Locale(identifier: "en_US")
    private let people = ["Priya Sharma", "Rahul Verma", "Ananya Iyer", "Kabir Rao", "Meera Nair"].map {
        QeetrixAvatarGroupPerson(name: $0)
    }

    @Test(
        "max avatars, then +N; one left over shows as a face, not +1",
        arguments: [
            // people, max, total → count, shown, rest
            (5, 3, nil, 5, 3, 2),
            (4, 3, nil, 4, 4, 0),
            (3, 3, nil, 3, 3, 0),
            (2, 3, nil, 2, 2, 0),
            (3, 3, 412, 412, 3, 409),
            (3, 3, 4, 4, 3, 1),  // only three are known, so the fourth is +1
            (5, 3, 2, 5, 3, 2),  // total never below the people given
            (0, 3, 12, 12, 0, 12),
            (5, 0, nil, 5, 0, 5),
        ] as [(Int, Int, Int?, Int, Int, Int)])
    func counts(people: Int, max: Int, total: Int?, count: Int, shown: Int, rest: Int) {
        let counts = QeetrixAvatarGroupCounts(people: people, max: max, total: total)
        #expect((counts.count, counts.shown, counts.rest) == (count, shown, rest))
    }

    @Test("VoiceOver reads the group in full: the count, the names shown and how many more")
    func name() {
        let counts = QeetrixAvatarGroupCounts(people: 3, max: 3, total: 412)
        #expect(
            QeetrixAvatarGroup.name(names: ["Priya Sharma", "Rahul Verma", "Ananya Iyer"], counts: counts, locale: english)
                == "412 people: Priya Sharma, Rahul Verma, Ananya Iyer, and 409 more")
        let all = QeetrixAvatarGroupCounts(people: 2, max: 3, total: nil)
        #expect(
            QeetrixAvatarGroup.name(names: ["Priya Sharma", "Rahul Verma"], counts: all, locale: english)
                == "2 people: Priya Sharma and Rahul Verma")
        let many = QeetrixAvatarGroupCounts(people: 1, max: 3, total: 1_412)
        #expect(
            QeetrixAvatarGroup.name(names: ["Priya Sharma"], counts: many, locale: english) == "1,412 people: Priya Sharma and 1,411 more")
    }

    @Test("+N is the rest, in the locale's digits")
    func more() {
        #expect(QeetrixAvatarGroup.more(409, locale: english) == "+409")
        #expect(QeetrixAvatarGroup.more(1_411, locale: english) == "+1,411")
    }

    @Test("+N is a pill, or square-cornered beside square avatars")
    func moreShape() {
        let rect = CGRect(x: 0, y: 0, width: 40, height: 24)
        let pill = QeetrixAvatarGroupMoreShape(shape: .circle).path(in: rect)
        #expect(!pill.contains(CGPoint(x: 2, y: 2)))
        #expect(pill.contains(CGPoint(x: 12, y: 12)))
        let square = QeetrixAvatarGroupMoreShape(shape: .square).path(in: rect)
        #expect(square.contains(CGPoint(x: 3, y: 3)))
        #expect(!square.contains(CGPoint(x: 0.3, y: 0.3)))
    }

    @Test("avatar-group.css: avatars 2 pt apart, +N the avatars' height on their fill")
    func drawn() throws {
        let view = QeetrixAvatarGroup(people: people, size: .md).environment(\.colorScheme, .light)
        let image = try #require(Rendered(view))
        // Three 32 pt avatars, 2 pt apart, then +2: at least the avatar's width.
        #expect(image.height == 32)
        #expect(image.width == 3 * 32 + 3 * 2 + 32)
        #expect(image.pixel(33, 16).a == 0, "the 2 pt gap between avatars")
        let fill = QeetrixTheme.light.resolve(.bgNeutralSubtlePressed).bytes
        #expect(close(fill, image.pixel(3 * 34 + 16, 4)))
    }

    @Test("Every size and shape renders, with images, repeats and a custom name")
    func renders() {
        for size in QeetrixAvatarSize.allCases {
            for shape in QeetrixAvatarShape.allCases {
                let view = QeetrixAvatarGroup(people: people + people, total: 30, size: size, shape: shape)
                #expect(ImageRenderer(content: view).cgImage != nil)
            }
        }
        let apps = QeetrixAvatarGroup(
            people: [QeetrixAvatarGroupPerson(name: "Pay", image: Image(systemName: "creditcard"))], shape: .square,
            label: Text("1 application: Pay"))
        #expect(ImageRenderer(content: apps).cgImage != nil)
    }
}
