import SwiftUI

/// The sizes of ``QeetrixAvatar``, as on the web. Fixed steps, not density- or Dynamic Type-scaled:
/// an avatar is a recognition target, so a person looks the same size everywhere.
public enum QeetrixAvatarSize: String, CaseIterable, Sendable {
    /// 20 pt.
    case xs
    /// 24 pt.
    case sm
    /// 32 pt.
    case `default`
    /// 40 pt.
    case lg
    /// 48 pt.
    case xl

    /// The avatar's width and height.
    public var points: CGFloat {
        switch self {
        case .xs: QeetrixWebScale.spacing(5)  // size-5
        case .sm: QeetrixWebScale.spacing(6)  // size-6
        case .default: QeetrixWebScale.spacing(8)  // size-8
        case .lg: QeetrixWebScale.spacing(10)  // size-10
        case .xl: QeetrixWebScale.spacing(12)  // size-12
        }
    }
}

/// The shapes of ``QeetrixAvatar``.
public enum QeetrixAvatarShape: String, CaseIterable, Sendable {
    /// For people.
    case circle
    /// For organisations, workspaces and apps, so they never read as people.
    case square
}

/// A person's picture, their initials, or a neutral icon.
///
/// ```swift
/// QeetrixAvatar(name: "Asha Rao")                                  // "AR"
/// QeetrixAvatar(name: "Asha Rao", image: photo, size: .lg, badge: Text("Online"))
/// QeetrixAvatar(name: "Qeet Group", shape: .square)
/// ```
///
/// Without an image it shows the initials of `name` — the first letters of its first and last words —
/// and without a name the `user-round` icon. VoiceOver reads the avatar as one image called by the
/// name, followed by the badge's text; colour alone is never the status. Pass `name: nil` when the
/// name is already visible beside the avatar, so it is not read twice: the avatar is then hidden from
/// VoiceOver unless it has a badge.
public struct QeetrixAvatar: View {
    let name: String?
    let image: Image?
    let size: QeetrixAvatarSize
    let shape: QeetrixAvatarShape
    let badge: Text?
    @Environment(\.colorScheme) private var colorScheme

    /// - Parameters:
    ///   - name: The person's or organisation's display name: the initials and the VoiceOver label.
    ///   - image: A picture, already loaded; it fills the avatar.
    ///   - size: One of the fixed sizes.
    ///   - shape: `circle` for people, `square` for organisations, workspaces and apps.
    ///   - badge: The status the badge mark stands for, such as "Online". The mark is drawn at the
    ///     bottom-trailing edge and the text is read by VoiceOver.
    public init(
        name: String?, image: Image? = nil, size: QeetrixAvatarSize = .default, shape: QeetrixAvatarShape = .circle, badge: Text? = nil
    ) {
        self.name = name
        self.image = image
        self.size = size
        self.shape = shape
        self.badge = badge
    }

    public var body: some View {
        let side = size.points
        let outline = Self.outline(shape)
        ZStack {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: side, height: side)
            } else {
                outline.fill(QeetrixAvatarTokens.fallbackBackground)
                fallback(side: side)
                    .foregroundStyle(QeetrixAvatarTokens.fallbackForeground)
            }
        }
        .frame(width: side, height: side)
        .clipShape(outline)
        .overlay {
            // A hairline that keeps a pale photo from bleeding into a pale surface, and a dark one
            // into a dark surface; it blends, so it never reads as a drawn border.
            outline
                .strokeBorder(QeetrixColor.borderDefault, lineWidth: QeetrixStroke.hairline)
                .blendMode(colorScheme == .dark ? .lighten : .darken)
        }
        .overlay(alignment: .bottomTrailing) {
            if badge != nil {
                badgeMark
            }
        }
        .modifier(QeetrixAvatarAccessibility(name: name, badge: badge))
    }

    @ViewBuilder
    private func fallback(side: CGFloat) -> some View {
        if let name, case let initials = Self.initials(name), !initials.isEmpty {
            Text(verbatim: initials)
                .qeetrixType(Self.initialsType(size))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        } else {
            // Sized to the avatar, which doesn't scale with Dynamic Type, as the initials are.
            QeetrixIcon(.userRound, size: QeetrixIconSize(side * 0.55), relativeTo: nil)  // [&>svg]:size-[55%]
        }
    }

    private var badgeMark: some View {
        let metrics = Self.badgeMetrics(size)
        let outset = shape == .square ? QeetrixWebScale.spacing(0.5) : 0  // -inset-e-0.5 -bottom-0.5
        return Circle()
            .fill(QeetrixAvatarTokens.badgeBackground)
            .frame(width: metrics.size, height: metrics.size)
            .background {
                Circle()
                    .fill(QeetrixAvatarTokens.ring)
                    .padding(-metrics.ring)  // ring-2, ring-1 at xs
            }
            .offset(x: outset, y: outset)
            .flipsForRightToLeftLayoutDirection(true)
    }

    static func outline(_ shape: QeetrixAvatarShape) -> QeetrixAvatarOutline {
        QeetrixAvatarOutline(shape: shape)
    }

    /// Up to two initials: the first character of the first and the last word, upper-cased for the
    /// current locale. One word gives one initial ("Priya" is "P"); a name in a script without word
    /// spaces gives its first character.
    static func initials(_ name: String) -> String {
        let words = name.split(whereSeparator: \.isWhitespace)
        guard let first = words.first?.first else { return "" }
        let last = words.count > 1 ? words.last?.first.map(String.init) ?? "" : ""
        return (String(first) + last).uppercased(with: .current)
    }

    /// `font-ui font-medium` at `text-micro` (xs, sm), `text-sm`, `text-base` (lg) or `text-lg` (xl),
    /// fixed so the initials never outgrow the avatar.
    static func initialsType(_ size: QeetrixAvatarSize) -> QeetrixTypeSpec {
        let micro = QeetrixTextRole.micro.tokens
        let step: QeetrixWebScale.TextStep =
            switch size {
            case .xs, .sm: .init(size: micro.size, lineHeight: micro.lineHeight)
            case .default: QeetrixWebScale.textSM
            case .lg: QeetrixWebScale.textBase
            case .xl: QeetrixWebScale.textLG
            }
        return QeetrixComponentType.ui(step, .medium, scalesLike: nil)
    }

    /// The badge mark's diameter and ring: `size-1.5 ring-1` at xs, then `size-2`, `size-2.5`,
    /// `size-3`, `size-3.5` with `ring-2`.
    static func badgeMetrics(_ size: QeetrixAvatarSize) -> (size: CGFloat, ring: CGFloat) {
        switch size {
        case .xs: (QeetrixWebScale.spacing(1.5), 1)
        case .sm: (QeetrixWebScale.spacing(2), 2)
        case .default: (QeetrixWebScale.spacing(2.5), 2)
        case .lg: (QeetrixWebScale.spacing(3), 2)
        case .xl: (QeetrixWebScale.spacing(3.5), 2)
        }
    }
}

/// A circle, or a square with corners of 25% of its side (`avatar.corner-square`). Insetting keeps
/// the corners concentric, so the hairline drawn inside follows the edge exactly.
struct QeetrixAvatarOutline: InsettableShape {
    let shape: QeetrixAvatarShape
    var inset: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let inner = rect.insetBy(dx: inset, dy: inset)
        switch shape {
        case .circle:
            return Path(ellipseIn: inner)
        case .square:
            let radius = max(0, min(rect.width, rect.height) * QeetrixAvatarTokens.cornerSquare - inset)
            return Path(roundedRect: inner, cornerRadius: radius)
        }
    }

    func inset(by amount: CGFloat) -> QeetrixAvatarOutline {
        var outline = self
        outline.inset += amount
        return outline
    }
}

private struct QeetrixAvatarAccessibility: ViewModifier {
    let name: String?
    let badge: Text?

    func body(content: Content) -> some View {
        switch (name, badge) {
        case (nil, nil):
            content.accessibilityHidden(true)
        case (let name?, let badge):
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(badge.map { Text(verbatim: name + ", ") + $0 } ?? Text(verbatim: name))
                .accessibilityAddTraits(.isImage)
        case (nil, let badge?):
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(badge)
        }
    }
}
