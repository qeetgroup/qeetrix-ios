import SwiftUI

/// The label of a group of rows — Qeetrix's group label (design rules §5): small, tracked capitals in
/// `typography.label.caps` and `color.text.subtlest`, under a 1 pt `color.border.subtle` rule, as the
/// web Sidebar labels its groups. Above a `Section` of a `List`, or above a group of
/// ``QeetrixListItem``s in a stack; an optional description and action follow.
///
/// ```swift
/// List {
///     Section {
///         QeetrixListItem("Face ID", isOn: $faceID)
///     } header: {
///         QeetrixSectionHeader("Security", isRuled: false)
///     }
///     Section {
///         ForEach(devices) { device in QeetrixListItem(device.name) }
///     } header: {
///         QeetrixSectionHeader("Signed-in devices", description: Text("Where your account is in use.")) {
///             QeetrixButton("Sign out all", variant: .ghost, tone: .danger, size: .sm) { signOutAll() }
///         }
///     }
/// }
/// .qeetrixListStyle()
/// ```
///
/// `@qeetrix/react` has no section header for rows, so this is iOS's, with qeetrix-android's API,
/// drawn as `.qx-sidebar-group-label` (sidebar.css): `space.gap.sm` and the rule above it,
/// `space.inset.md` from the rule to the label, 6 pt from the label to the rows, the rows' 16 pt
/// inset. Pass `isRuled: false` for the first group, as the Sidebar's first group has no rule.
///
/// - **Write the title in sentence case** ("Signed-in devices"): the capitals are styling, so
///   VoiceOver reads the words as written, and Indic text — which has no capitals — renders as written,
///   without the tracking (sidebar.css drops it for Hindi, Marathi, Bengali, Tamil and the other Indic
///   languages).
/// - VoiceOver reads the title and the description as one heading, so the rotor moves between groups;
///   the action is its own control — typically a ghost ``QeetrixButton``.
/// - In a `List` it sets its own insets and turns off the list's header capitals. A plain list's
///   header stays pinned while its rows scroll under it: give it the surface it sits on with
///   `background(_:)`.
public struct QeetrixSectionHeader<Action: View>: View {
    let title: Text
    let description: Text?
    let isRuled: Bool
    let isIndicTitle: Bool
    let action: Action
    @Environment(\.locale) private var locale

    init(title: Text, description: Text?, isRuled: Bool, isIndicTitle: Bool, action: () -> Action) {
        self.title = title
        self.description = description
        self.isRuled = isRuled
        self.isIndicTitle = isIndicTitle
        self.action = action()
    }

    /// A section header with a localised title.
    ///
    /// - Parameters:
    ///   - titleKey: The group's name, in sentence case: the capitals are styling.
    ///   - description: A sentence under the label, `body.sm` in `color.text.subtle`, as written.
    ///   - isRuled: Draws the rule above the label; `false` for a list's first group.
    ///   - action: At the header's end: an action on the whole group, such as a ghost button.
    public init(
        _ titleKey: LocalizedStringKey, description: Text? = nil, isRuled: Bool = true,
        @ViewBuilder action: () -> Action = { EmptyView() }
    ) {
        self.init(title: Text(titleKey), description: description, isRuled: isRuled, isIndicTitle: false, action: action)
    }

    /// A section header with a title shown as given. An Indic title drops the tracking, whatever the
    /// app's language.
    public init<S: StringProtocol>(
        _ title: S, description: Text? = nil, isRuled: Bool = true, @ViewBuilder action: () -> Action = { EmptyView() }
    ) {
        self.init(
            title: Text(title), description: description, isRuled: isRuled, isIndicTitle: QeetrixSectionHeaderMetrics.isIndic(title),
            action: action)
    }

    /// A section header with a `Text` title.
    public init(title: Text, description: Text? = nil, isRuled: Bool = true, @ViewBuilder action: () -> Action = { EmptyView() }) {
        self.init(title: title, description: description, isRuled: isRuled, isIndicTitle: false, action: action)
    }

    public var body: some View {
        let untracked = isIndicTitle || QeetrixSectionHeaderMetrics.isIndic(locale)
        HStack(spacing: QeetrixSpace.gapMd) {
            VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                (untracked ? title.tracking(0) : title)
                    .qeetrixTextStyle(.labelCaps)
                    // text-transform: uppercase, for the locale; VoiceOver reads the title as written.
                    .textCase(.uppercase)
                    .foregroundStyle(QeetrixColor.textSubtlest)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(title)
                if let description {
                    description
                        .qeetrixTextStyle(.bodySm)
                        .foregroundStyle(QeetrixColor.textSubtle)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            action
        }
        .padding(.horizontal, QeetrixListItemMetrics.inlinePadding)
        .padding(.top, QeetrixSectionHeaderMetrics.topPadding(isRuled: isRuled))
        .padding(.bottom, QeetrixSectionHeaderMetrics.bottomPadding)
        .overlay(alignment: .top) {
            if isRuled {
                QeetrixSeparator()
                    .padding(.top, QeetrixSpace.gapSm)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // A list's header capitalises its text and insets it; the header does both itself.
        .textCase(nil)
        .listRowInsets(EdgeInsets())
    }
}

/// The header's metrics, from sidebar.css.
enum QeetrixSectionHeaderMetrics {
    /// `.qx-sidebar-group-label { padding-block-end: 6px }`.
    static let bottomPadding: CGFloat = 6

    /// `.qx-sidebar-group + .qx-sidebar-group`: `margin-block-start` gap.sm, the 1 pt rule, then
    /// `padding-block-start` inset.md. The first group: the nav's `padding-block-start` gap.sm.
    static func topPadding(isRuled: Bool) -> CGFloat {
        isRuled ? QeetrixSpace.gapSm + QeetrixBorderWidth.default + QeetrixSpace.insetMd : QeetrixSpace.gapSm
    }

    /// sidebar.css `:lang(hi, mr, bn, gu, pa, or, ta, te, kn, ml)`: `letter-spacing: 0`.
    static let indicLanguages: Set<String> = ["hi", "mr", "bn", "gu", "pa", "or", "ta", "te", "kn", "ml"]

    static func isIndic(_ locale: Locale) -> Bool {
        locale.language.languageCode.map { indicLanguages.contains($0.identifier) } ?? false
    }

    /// Whether `text` is written in an Indic script — by its letters, so a Hindi title in an English
    /// app drops the tracking too: Devanagari, Bengali, Gurmukhi, Gujarati, Oriya, Tamil, Telugu,
    /// Kannada and Malayalam (U+0900–U+0D7F).
    static func isIndic<S: StringProtocol>(_ text: S) -> Bool {
        text.unicodeScalars.contains { (0x0900...0x0D7F).contains($0.value) }
    }
}
