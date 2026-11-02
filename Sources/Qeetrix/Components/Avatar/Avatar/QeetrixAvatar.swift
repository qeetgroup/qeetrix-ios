import SwiftUI

/// The sizes of ``QeetrixAvatar``, as `@qeetrix/react`'s `AvatarSize`.
public enum QeetrixAvatarSize: String, CaseIterable, Sendable {
    /// 24 pt.
    case sm
    /// 32 pt, the default.
    case md
    /// 40 pt.
    case lg
    /// 48 pt.
    case xl

    /// The avatar's width and height.
    public var points: CGFloat {
        switch self {
        case .sm: 24
        case .md: 32
        case .lg: 40
        case .xl: 48
        }
    }
}

/// Who an avatar stands for, as `@qeetrix/react`'s `AvatarShape`.
public enum QeetrixAvatarShape: String, CaseIterable, Sendable {
    /// A person: people are one of the two soft shapes (design rules §3).
    case circle
    /// An organisation, an application or a tenant, with the controls' 4 pt corners, so it never
    /// reads as a person.
    case square
}

/// A person, organisation or application: their photo or logo, or their initials on a neutral fill —
/// `@qeetrix/react`'s Avatar.
///
/// ```swift
/// QeetrixAvatar(name: "Priya Sharma", image: Image("priya"))
/// QeetrixAvatar(name: "Kaveri Foods Private Limited", size: .lg, shape: .square)  // "KF"
/// ```
///
/// The initials are the first characters of the first and last words ("Priya Sharma" is "PS"); a
/// company's legal form doesn't count, and a name left with one word takes its first two. They are
/// grapheme clusters, so Indic names stay whole. VoiceOver reads the avatar as an image named by
/// `name`; with `isDecorative`, where the name is shown beside it, it is hidden.
public struct QeetrixAvatar: View {
    let name: String
    let image: Image?
    let size: QeetrixAvatarSize
    let shape: QeetrixAvatarShape
    let isDecorative: Bool

    public init(
        name: String, image: Image? = nil, size: QeetrixAvatarSize = .md, shape: QeetrixAvatarShape = .circle, isDecorative: Bool = false
    ) {
        self.name = name
        self.image = image
        self.size = size
        self.shape = shape
        self.isDecorative = isDecorative
    }

    public var body: some View {
        let side = size.points
        let outline = QeetrixAvatarOutline(shape: shape)
        ZStack {
            outline.fill(QeetrixColor.bgNeutralSubtlePressed)
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: side, height: side)
            } else {
                Text(verbatim: Self.initials(name))
                    .qeetrixTypeEnvironment(Self.initialsType(size))
                    .foregroundStyle(QeetrixColor.textDefault)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .frame(width: side, height: side)
        .clipShape(outline)
        .modifier(QeetrixAvatarAccessibility(name: name, isDecorative: isDecorative))
    }

    /// Legal forms that end a company's name, with or without dots ("Acme Pvt. Ltd." is Acme), as on
    /// the web.
    static let legalForms: Set<String> = [
        "pvt", "private", "ltd", "limited", "llp", "opc", "inc", "incorporated", "llc", "plc", "corp", "co", "gmbh", "pte", "pty",
    ]

    static func isLegalForm(_ word: Substring) -> Bool {
        legalForms.contains(word.filter { $0 != "." && $0 != "," }.lowercased())
    }

    /// The first grapheme of the first and last words, skipping trailing legal forms; one word left
    /// gives its first two.
    static func initials(_ name: String) -> String {
        let words = name.split(whereSeparator: \.isWhitespace)
        guard let first = words.first else { return "" }
        var kept = words.count
        while kept > 1, isLegalForm(words[kept - 1]) { kept -= 1 }
        if kept == 1, kept < words.count {
            return String(first.prefix(2)).uppercased(with: .current)
        }
        let last = kept > 1 ? String(words[kept - 1].prefix(1)) : ""
        return (String(first.prefix(1)) + last).uppercased(with: .current)
    }

    /// `label.sm`, or `label.md` at `lg` and `xl`, at its token size: the initials sit in a fixed-size
    /// graphic, so they don't grow with Dynamic Type.
    static func initialsType(_ size: QeetrixAvatarSize) -> QeetrixTypeSpec {
        QeetrixComponentType.fixed(size == .lg || size == .xl ? .labelMd : .labelSm)
    }
}

struct QeetrixAvatarOutline: InsettableShape {
    let shape: QeetrixAvatarShape
    var inset: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let inner = rect.insetBy(dx: inset, dy: inset)
        switch shape {
        case .circle:
            return Path(ellipseIn: inner)
        case .square:
            return Path(roundedRect: inner, cornerRadius: max(0, QeetrixRadius.control - inset))
        }
    }

    func inset(by amount: CGFloat) -> QeetrixAvatarOutline {
        var outline = self
        outline.inset += amount
        return outline
    }
}

private struct QeetrixAvatarAccessibility: ViewModifier {
    let name: String
    let isDecorative: Bool

    func body(content: Content) -> some View {
        if isDecorative {
            content.accessibilityHidden(true)
        } else {
            // One image named by `name`. A representation rather than `children: .ignore`, which on
            // iOS 26 and later still lists the initials as a text inside the image.
            content
                .accessibilityRepresentation {
                    Color.clear
                        .accessibilityLabel(Text(verbatim: name))
                        .accessibilityAddTraits(.isImage)
                }
        }
    }
}
