import SwiftUI

/// One person, organisation or application in a ``QeetrixAvatarGroup``.
public struct QeetrixAvatarGroupPerson {
    /// Their name: part of the group's name for VoiceOver, and the source of the initials.
    public let name: String
    /// Their photo or logo.
    public let image: Image?

    public init(name: String, image: Image? = nil) {
        self.name = name
        self.image = image
    }
}

/// A few people at a glance — a group's members, an application's users — as `@qeetrix/react`'s
/// AvatarGroup: the first `max` avatars side by side, then +N for the rest.
///
/// ```swift
/// QeetrixAvatarGroup(people: [
///     QeetrixAvatarGroupPerson(name: "Priya Sharma"),
///     QeetrixAvatarGroupPerson(name: "Rahul Verma"),
///     QeetrixAvatarGroupPerson(name: "Ananya Iyer"),
/// ], total: 412)
/// ```
///
/// The avatars are ``QeetrixAvatar``s of `size` (`sm` by default, for table rows) and `shape`, 2 pt
/// apart (`border.width.strong`) — never overlapped, so initials stay whole on any surface, a selected
/// row's included. +N is a pill the avatars' height on their fill, square-cornered for `square`
/// avatars; one left over shows as a face, not "+1". `total` is everyone, when `people` holds only the
/// first few; names may repeat.
///
/// VoiceOver reads the group as one image, named in full: "412 people: Priya Sharma, Rahul Verma,
/// Ananya Iyer and 409 more", the counts and the list in the app's language. For organisations or
/// applications, say what they are with `label`. The avatars don't grow with Dynamic Type, as an
/// avatar doesn't.
public struct QeetrixAvatarGroup: View {
    let people: [QeetrixAvatarGroupPerson]
    let limit: Int
    let total: Int?
    let size: QeetrixAvatarSize
    let shape: QeetrixAvatarShape
    let label: Text?
    @Environment(\.locale) private var locale

    /// - Parameters:
    ///   - people: Everyone, or the first few of them when `total` is larger.
    ///   - max: How many avatars to show before +N; 3 by default.
    ///   - total: How many there are in all — a group's 412 members.
    ///   - size: The avatars' size; `sm` by default.
    ///   - shape: `circle` for people, `square` for organisations, applications or tenants.
    ///   - label: Replaces the name VoiceOver reads, such as "3 applications: Pay, People and Logs".
    public init(
        people: [QeetrixAvatarGroupPerson], max: Int = 3, total: Int? = nil, size: QeetrixAvatarSize = .sm,
        shape: QeetrixAvatarShape = .circle, label: Text? = nil
    ) {
        self.people = people
        limit = max
        self.total = total
        self.size = size
        self.shape = shape
        self.label = label
    }

    public var body: some View {
        let counts = QeetrixAvatarGroupCounts(people: people.count, max: limit, total: total)
        let shown = Array(people.prefix(counts.shown))
        HStack(spacing: QeetrixBorderWidth.strong) {
            ForEach(shown.indices, id: \.self) { index in
                QeetrixAvatar(name: shown[index].name, image: shown[index].image, size: size, shape: shape, isDecorative: true)
            }
            if counts.rest > 0 {
                QeetrixAvatarGroupMore(text: Self.more(counts.rest, locale: locale), size: size, shape: shape)
            }
        }
        .fixedSize()
        // One image, named in full. A representation rather than `children: .ignore`, as for an avatar.
        .accessibilityRepresentation {
            Color.clear
                .accessibilityLabel(label ?? Text(verbatim: Self.name(names: shown.map(\.name), counts: counts, locale: locale)))
                .accessibilityAddTraits(.isImage)
        }
    }

    /// "+409", the count in the locale's digits.
    static func more(_ rest: Int, locale: Locale) -> String {
        "+" + rest.formatted(.number.locale(locale))
    }

    /// "412 people: Priya Sharma, Rahul Verma, Ananya Iyer and 409 more" — `avatarGroup.label` and
    /// `avatarGroup.more`, the list joined as the locale joins one.
    static func name(names: [String], counts: QeetrixAvatarGroupCounts, locale: Locale) -> String {
        var items = names
        if counts.rest > 0 {
            items.append(
                String(localized: "qeetrix.avatar-group.more", defaultValue: "\(counts.rest) more", bundle: .module, locale: locale))
        }
        return String(
            localized: "qeetrix.avatar-group.label", defaultValue: "\(counts.count) people: \(items, format: .list(type: .and))",
            bundle: .module, locale: locale)
    }
}

/// How many people there are, how many avatars show, and how many +N stands for, as the web counts:
/// `max` avatars, or all of them when only one would be left over.
struct QeetrixAvatarGroupCounts: Equatable {
    let count: Int
    let shown: Int
    let rest: Int

    init(people: Int, max limit: Int, total: Int?) {
        let limit = max(0, limit)
        count = max(total ?? people, people)
        shown = min(people, count - limit == 1 ? limit + 1 : limit)
        rest = count - shown
    }
}

/// +N (avatar-group.css `.qx-avatar-group-more`): the avatar's height and at least its width, 4 pt
/// either side of the count, a pill — or the controls' corners beside square avatars — on the
/// avatar's fill, in the initials' type with tabular figures.
private struct QeetrixAvatarGroupMore: View {
    let text: String
    let size: QeetrixAvatarSize
    let shape: QeetrixAvatarShape

    var body: some View {
        let side = size.points
        Text(verbatim: text)
            .qeetrixTypeEnvironment(QeetrixAvatar.initialsType(size))
            .monospacedDigit()
            .lineLimit(1)
            .foregroundStyle(QeetrixColor.textDefault)
            .padding(.horizontal, QeetrixSpace.gapXs)
            .frame(minWidth: side)
            .frame(height: side)
            .background(QeetrixColor.bgNeutralSubtlePressed, in: QeetrixAvatarGroupMoreShape(shape: shape))
    }
}

/// A pill, or a rectangle with the controls' 4 pt corners (`[data-shape="square"]`).
struct QeetrixAvatarGroupMoreShape: Shape {
    let shape: QeetrixAvatarShape

    func path(in rect: CGRect) -> Path {
        let radius = shape == .square ? QeetrixRadius.control : rect.height / 2
        return Path(roundedRect: rect, cornerRadius: min(radius, rect.height / 2))
    }
}
