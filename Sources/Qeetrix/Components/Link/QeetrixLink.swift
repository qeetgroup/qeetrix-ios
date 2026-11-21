import SwiftUI

/// A link's colour, as `@qeetrix/react`'s `LinkTone`.
public enum QeetrixLinkTone: String, CaseIterable, Sendable {
    /// `color.text.link`, and `color.text.link-hover` while pressed or under a pointer. The default.
    case `default`
    /// `color.text.subtle`, and `color.text.default` while pressed: a quiet link in a footnote.
    case subtle
    /// The colour of the text round it, underlined.
    case inherit

    /// The colour at rest and while lit; `nil` keeps the surrounding colour.
    func color(isLit: Bool) -> QeetrixColor? {
        switch self {
        case .default: isLit ? .textLinkHover : .textLink
        case .subtle: isLit ? .textDefault : .textSubtle
        case .inherit: nil
        }
    }
}

/// A text link — `@qeetrix/react`'s Link — for an action in place under a field or after a paragraph
/// ("Change number", "Resend code") or a page to open.
///
/// ```swift
/// QeetrixLink("Change number") { goBack() }
/// QeetrixLink("Read in another language", icon: .globe) { showLanguages() }
/// QeetrixLink("Privacy Policy", destination: privacyURL, tone: .subtle)
/// ```
///
/// The text round it sets its font: give it a role with `.qeetrixTextStyle(_:)`, as the web's Link takes
/// the font of its paragraph. It is `color.text.link`, underlined 1 pt with the underline 3 pt under the
/// baseline (link.css); pressed, or under a pointer, `color.text.link-hover` with a 2 pt underline,
/// over `motion.duration.fast`. `tone` makes it `subtle` or the surrounding colour. An `icon` leads,
/// 16 pt and not underlined. Keyboard focus is the Ember frame round it.
///
/// It is a 44 pt target without changing the line's layout. VoiceOver reads an action as a button and a
/// `destination` as a link, by its words: write words that say where it goes. Inside a sentence, put
/// the link in the sentence's text instead (`AttributedString.qeetrixLinks()`).
public struct QeetrixLink: View {
    enum Target {
        case action(@MainActor () -> Void)
        case destination(URL)
    }

    let title: Text
    let icon: QeetrixIconName?
    let tone: QeetrixLinkTone
    let target: Target
    @Environment(\.openURL) private var openURL

    /// A link that acts in place, with a localised title.
    public init(
        _ titleKey: LocalizedStringKey, icon: QeetrixIconName? = nil, tone: QeetrixLinkTone = .default,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(title: Text(titleKey), icon: icon, tone: tone, action: action)
    }

    /// A link that acts in place, with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, icon: QeetrixIconName? = nil, tone: QeetrixLinkTone = .default, action: @escaping @MainActor () -> Void
    ) {
        self.init(title: Text(title), icon: icon, tone: tone, action: action)
    }

    /// A link that acts in place — the web's `<Link render={<button />}>` — with a `Text` title. VoiceOver
    /// reads it as a button.
    public init(title: Text, icon: QeetrixIconName? = nil, tone: QeetrixLinkTone = .default, action: @escaping @MainActor () -> Void) {
        self.title = title
        self.icon = icon
        self.tone = tone
        target = .action(action)
    }

    /// A link to a page, with a localised title.
    public init(_ titleKey: LocalizedStringKey, destination: URL, icon: QeetrixIconName? = nil, tone: QeetrixLinkTone = .default) {
        self.init(title: Text(titleKey), destination: destination, icon: icon, tone: tone)
    }

    /// A link to a page, with a title shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, destination: URL, icon: QeetrixIconName? = nil, tone: QeetrixLinkTone = .default) {
        self.init(title: Text(title), destination: destination, icon: icon, tone: tone)
    }

    /// A link to a page, with a `Text` title. It opens `destination` through the environment's
    /// `openURL`, so an app can handle it in place; VoiceOver reads it as a link.
    public init(title: Text, destination: URL, icon: QeetrixIconName? = nil, tone: QeetrixLinkTone = .default) {
        self.title = title
        self.icon = icon
        self.tone = tone
        target = .destination(destination)
    }

    public var body: some View {
        let link = Button {
            switch target {
            case .action(let action): action()
            case .destination(let url): openURL(url)
            }
        } label: {
            title
        }
        .buttonStyle(QeetrixLinkStyle(tone: tone, icon: icon))
        if case .destination = target {
            link.accessibilityRemoveTraits(.isButton).accessibilityAddTraits(.isLink)
        } else {
            link
        }
    }
}

/// The link's sizes (link.css `.qx-link`).
enum QeetrixLinkMetrics {
    /// `text-underline-offset: 3px`: the underline's top, under the baseline.
    static let underlineOffset: CGFloat = 3
    /// The leading icon: 16 pt (`size-4`), 6 pt (`gap-1.5`) before the words, as the approved mockups
    /// draw it; link.css has no leading icon.
    static let iconSize = QeetrixIconSize.sm
    static let iconGap: CGFloat = 6

    /// `text-decoration-thickness`: `border.width.default`, `border.width.strong` while lit.
    static func underlineThickness(isLit: Bool) -> CGFloat {
        isLit ? QeetrixBorderWidth.strong : QeetrixBorderWidth.default
    }
}

/// The link's look (link.css `.qx-link`) for its button.
struct QeetrixLinkStyle: ButtonStyle {
    let tone: QeetrixLinkTone
    let icon: QeetrixIconName?

    func makeBody(configuration: Configuration) -> some View {
        QeetrixLinkBody(style: self, configuration: configuration)
    }
}

private struct QeetrixLinkBody: View {
    let style: QeetrixLinkStyle
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        let isLit = isEnabled && (isHovered || configuration.isPressed)
        let thickness = QeetrixLinkMetrics.underlineThickness(isLit: isLit)
        // The icon is as tall as a body line's letters, so it is centred on the words rather than set on
        // their baseline, where it would make a one-line link taller than its text.
        HStack(alignment: .center, spacing: QeetrixLinkMetrics.iconGap) {
            if let icon = style.icon {
                QeetrixIcon(icon, size: QeetrixLinkMetrics.iconSize, shape: .sharp, relativeTo: .body)
            }
            configuration.label
                .multilineTextAlignment(.leading)
                .modifier(QeetrixLinkUnderline(thickness: thickness))
        }
        .modifier(QeetrixLinkColor(color: isEnabled ? style.tone.color(isLit: isLit) : .textDisabled))
        // `border-radius: radius.sm` and the focus outline round it.
        .overlay { if isFocused { QeetrixOuterFocusFrame(shape: RoundedRectangle(cornerRadius: QeetrixRadius.sm)) } }
        .qeetrixHitArea()
        .onHover { isHovered = $0 }
        .qeetrixAnimation(.standard, .fast, value: isLit)
    }
}

/// The tone's colour, or the surrounding one.
private struct QeetrixLinkColor: ViewModifier {
    let color: QeetrixColor?

    func body(content: Content) -> some View {
        if let color {
            content.foregroundStyle(color)
        } else {
            content
        }
    }
}

/// The underline: drawn by Qeetrix 3 pt under each line's baseline where the system can draw text that
/// way (iOS 18), else the font's own underline, which sits where the font puts it.
struct QeetrixLinkUnderline: ViewModifier {
    let thickness: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 18, macOS 15, *) {
            content.textRenderer(QeetrixLinkUnderlineRenderer(thickness: thickness))
        } else {
            content.underline()
        }
    }
}

/// Draws each line, then its underline: `thickness` tall, its top `underlineOffset` under the baseline,
/// as wide as the line, in the text's colour.
@available(iOS 18, macOS 15, *)
struct QeetrixLinkUnderlineRenderer: TextRenderer {
    var thickness: CGFloat

    var animatableData: CGFloat {
        get { thickness }
        set { thickness = newValue }
    }

    var displayPadding: EdgeInsets {
        EdgeInsets(top: 0, leading: 0, bottom: QeetrixLinkMetrics.underlineOffset + thickness, trailing: 0)
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for line in layout {
            context.draw(line)
            let bounds = line.typographicBounds
            let underline = CGRect(
                x: bounds.rect.minX, y: bounds.origin.y + QeetrixLinkMetrics.underlineOffset, width: bounds.width, height: thickness)
            context.fill(Path(underline), with: .foreground)
        }
    }
}

extension AttributedString {
    /// The text with each of its links underlined, as `@qeetrix/react`'s Link inside a sentence: for
    /// "you accept the Terms of Service and Privacy Policy" in one localised string.
    ///
    /// ```swift
    /// Text(AttributedString(localized: "By continuing you accept the [Terms of Service](https://qeet.in/terms).").qeetrixLinks())
    ///     .qeetrixTextStyle(.bodySm)
    ///     .qeetrixLinkTone()
    /// ```
    ///
    /// The links keep the sentence's font. `.qeetrixLinkTone(_:)` on the text gives them the tone's
    /// colour; the system draws the underline at the font's own position and marks a pressed link
    /// itself. A tap opens the link through the environment's `openURL`, so an app can act on it in
    /// place; VoiceOver offers the links in its rotor.
    public func qeetrixLinks() -> AttributedString {
        var text = self
        for run in runs where run.link != nil {
            text[run.range].swiftUI.underlineStyle = .single
            // A link takes the view's tint (`qeetrixLinkTone(_:)`), not a colour of its own.
            text[run.range].swiftUI.foregroundColor = nil
        }
        return text
    }
}

extension View {
    /// Colours the links in this view's text in a ``QeetrixLinkTone``: `color.text.link` by default, or
    /// `color.text.subtle`, or the text's own colour. Underline them with
    /// `AttributedString.qeetrixLinks()`.
    public func qeetrixLinkTone(_ tone: QeetrixLinkTone = .default) -> some View {
        modifier(QeetrixLinkTint(tone: tone))
    }
}

private struct QeetrixLinkTint: ViewModifier {
    let tone: QeetrixLinkTone

    func body(content: Content) -> some View {
        if let color = tone.color(isLit: false) {
            content.tint(color)
        } else {
            content.tint(ForegroundStyle())
        }
    }
}
