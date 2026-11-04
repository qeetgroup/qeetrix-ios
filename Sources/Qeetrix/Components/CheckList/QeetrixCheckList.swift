import SwiftUI

/// A check's result, as `@qeetrix/react`'s `CheckStatus`: shown as an icon and in words.
public enum QeetrixCheckStatus: String, CaseIterable, Sendable {
    /// Met: the sharp `circle-check` in `color.icon.success`, "Passed" in `color.text.success`.
    case passed
    /// Not met: the sharp `circle-x` in `color.icon.danger`, "Failed" in `color.text.danger`.
    case failed
    /// Not checked yet: the sharp `circle-dashed` in `color.icon.subtle`, "Not run".
    case pending
    /// Being checked: a small spinner in `color.icon.subtle`, "Running".
    case running
}

/// Rules that tick as they're met — a new password's rules, a setup's steps, a connection test's
/// checks — each with its result in words as well as its icon, on a ruled sheet with an optional
/// footer: `@qeetrix/react`'s CheckList.
///
/// ```swift
/// QeetrixCheckList {
///     QeetrixCheckItem("At least 12 characters", status: password.count >= 12 ? .passed : .pending)
///     QeetrixCheckItem("Not a password you've used before", status: isReused ? .failed : .passed)
/// }
/// ```
///
/// The sheet is `color.surface.raised` inside a 1 pt `color.border.default` edge with 4 pt corners
/// (`radius.surface`); its items are ruled in `color.border.subtle`; the footer — when the checks ran,
/// a "Run again" button — is `body.sm` in `color.text.subtle` under its own rule, its parts at the two
/// ends, wrapping. The app decides each status; the list checks nothing itself.
public struct QeetrixCheckList<Content: View, Footer: View>: View {
    let content: Content
    let footer: Footer

    /// - Parameters:
    ///   - content: The ``QeetrixCheckItem``s.
    ///   - footer: Under the checks: when they ran, and a button to run them again.
    public init(@ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer = { EmptyView() }) {
        self.content = content()
        self.footer = footer()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.surface)
        VStack(alignment: .leading, spacing: 0) {
            // A 1 pt gap between items, where each item after the first draws its rule
            // (`.qx-check-item + .qx-check-item { border-block-start }`).
            VStack(alignment: .leading, spacing: QeetrixBorderWidth.default) {
                content
            }
            .coordinateSpace(.named(QeetrixCheckListMetrics.space))
            .environment(\.qeetrixIsInCheckList, true)
            .accessibilityElement(children: .contain)
            if Footer.self != EmptyView.self {
                QeetrixSeparator()
                // .qx-check-list-footer: padding inset.sm inset.md, body.sm, text.subtle
                QeetrixCheckListFooterLayout(spacing: QeetrixSpace.gapSm) {
                    footer
                }
                .qeetrixTypeEnvironment(QeetrixTypeSpec(.bodySm))
                .foregroundStyle(QeetrixColor.textSubtle)
                .padding(.vertical, QeetrixSpace.insetSm)
                .padding(.horizontal, QeetrixSpace.insetMd)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(QeetrixColor.surfaceRaised, in: shape)
        .overlay { shape.strokeBorder(QeetrixColor.borderDefault, lineWidth: QeetrixBorderWidth.default) }
    }
}

/// One check of a ``QeetrixCheckList``: its status icon, its title and an optional detail, and its
/// status in words at the end — `@qeetrix/react`'s CheckItem.
///
/// ```swift
/// QeetrixCheckItem("The certificate is in date", detail: Text("Until 23 Aug 2030"), status: .passed)
/// QeetrixCheckItem("The metadata URL answers", status: .running)
/// ```
///
/// VoiceOver reads each check as one element, with its status: "At least 12 characters, Passed". When
/// a status changes — a rule met as the person types, a check finishing — VoiceOver announces the
/// title and the new status at low priority, after what it is saying, as the web's polite live region
/// does. The title is a plain string, localised on creation, because it is also announced.
public struct QeetrixCheckItem: View {
    let title: String
    let detail: Text?
    let status: QeetrixCheckStatus
    let statusLabel: String?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.qeetrixIsInCheckList) private var isInList
    @ScaledMetric(relativeTo: .body) private var rem: CGFloat = QeetrixCheckListMetrics.rem
    @ScaledMetric(relativeTo: .body) private var iconSide: CGFloat = QeetrixIconSize.sm.points

    /// A check with a title localised from the main bundle.
    ///
    /// - Parameters:
    ///   - title: What's checked: "The certificate is in date". It is also announced.
    ///   - detail: What it found, or what it checks: "Until 23 Aug 2030". `body.sm` in
    ///     `color.text.subtle`, wrapping.
    ///   - status: The result.
    ///   - statusLabel: The status in words, already localised, instead of the built-in "Passed",
    ///     "Failed", "Not run" or "Running".
    public init(_ title: LocalizedStringResource, detail: Text? = nil, status: QeetrixCheckStatus, statusLabel: String? = nil) {
        self.init(verbatim: String(localized: title), detail: detail, status: status, statusLabel: statusLabel)
    }

    /// A check with a title shown as given.
    public init<S: StringProtocol>(_ title: S, detail: Text? = nil, status: QeetrixCheckStatus, statusLabel: String? = nil) {
        self.init(verbatim: String(title), detail: detail, status: status, statusLabel: statusLabel)
    }

    private init(verbatim title: String, detail: Text?, status: QeetrixCheckStatus, statusLabel: String?) {
        self.title = title
        self.detail = detail
        self.status = status
        self.statusLabel = statusLabel
    }

    /// The status in words.
    var statusText: String {
        statusLabel ?? status.label
    }

    public var body: some View {
        let isLarge = dynamicTypeSize.isAccessibilitySize
        // .qx-check-item: grid auto | 1fr | auto, gap.md, centred, min-block-size 3rem,
        // padding inset.sm inset.md.
        HStack(spacing: QeetrixSpace.gapMd) {
            icon
                .frame(width: iconSide, height: iconSide)
                .foregroundStyle(status.iconColor)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                Text(verbatim: title)
                    .qeetrixTextStyle(.labelMd)
                    .foregroundStyle(QeetrixColor.textDefault)
                    .fixedSize(horizontal: false, vertical: true)
                if let detail {
                    detail
                        .qeetrixTextStyle(.bodySm)
                        .foregroundStyle(QeetrixColor.textSubtle)
                        .fixedSize(horizontal: false, vertical: true)
                }
                // From the accessibility sizes the status moves under the text instead of squeezing it.
                if isLarge { statusView }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if !isLarge { statusView }
        }
        .padding(.vertical, QeetrixSpace.insetSm)
        .padding(.horizontal, QeetrixSpace.insetMd)
        .frame(maxWidth: .infinity, minHeight: QeetrixCheckListMetrics.minimumHeight * rem, alignment: .leading)
        .background(alignment: .top) { if isInList { QeetrixCheckListRule() } }
        .accessibilityElement(children: .combine)
        .onChange(of: status) { _, _ in
            AccessibilityNotification.Announcement(announcement).post()
        }
    }

    @ViewBuilder private var icon: some View {
        if let name = status.icon {
            QeetrixIcon(name, size: .sm, shape: .sharp)
        } else {
            // The web's `<Spinner decorative size="sm">`, growing with the icons it stands among.
            QeetrixSpinner(size: .sm, isDecorative: true)
                .scaleEffect(iconSide / QeetrixIconSize.sm.points)
        }
    }

    private var statusView: some View {
        Text(verbatim: statusText)
            .qeetrixTextStyle(.labelSm)
            .foregroundStyle(status.textColor)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// "Title, Passed", queued behind what VoiceOver is saying (the web's `aria-live="polite"`).
    var announcement: AttributedString {
        var text = AttributedString("\(title), \(statusText)")
        text.accessibilitySpeechAnnouncementPriority = .low
        return text
    }
}

extension QeetrixCheckStatus {
    /// check-list.js's icons; `nil` for the spinner.
    var icon: QeetrixIconName? {
        switch self {
        case .passed: .circleCheck
        case .failed: .circleX
        case .pending: .circleDashed
        case .running: nil
        }
    }

    /// check-list.css `.qx-check-item-icon`, and its `[data-status]` rules.
    var iconColor: QeetrixColor {
        switch self {
        case .passed: .iconSuccess
        case .failed: .iconDanger
        case .pending, .running: .iconSubtle
        }
    }

    /// check-list.css `.qx-check-item-status`, and its `[data-status]` rules.
    var textColor: QeetrixColor {
        switch self {
        case .passed: .textSuccess
        case .failed: .textDanger
        case .pending, .running: .textSubtle
        }
    }

    /// The built-in words, `@qeetrix/react`'s `checkList` messages.
    var label: String {
        switch self {
        case .passed: String(localized: "qeetrix.check-list.passed", defaultValue: "Passed", bundle: .module)
        case .failed: String(localized: "qeetrix.check-list.failed", defaultValue: "Failed", bundle: .module)
        case .pending: String(localized: "qeetrix.check-list.pending", defaultValue: "Not run", bundle: .module)
        case .running: String(localized: "qeetrix.check-list.running", defaultValue: "Running", bundle: .module)
        }
    }
}

/// The footer's parts (`.qx-check-list-footer`: flex, `justify-content: space-between`, `align-items:
/// center`, `flex-wrap: wrap`, `gap: space.gap.sm`): on one line, the first at the start and the last
/// at the end; on lines of their own when they don't fit, each at the start.
struct QeetrixCheckListFooterLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width.flatMap { $0.isFinite ? $0 : nil }
        let lines = QeetrixDescriptionValueLayout(spacing: spacing).lines(width: width, subviews: subviews)
        let height = lines.map(\.height).reduce(0, +) + spacing * CGFloat(max(0, lines.count - 1))
        return CGSize(width: width ?? lines.map(\.width).max() ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for line in QeetrixDescriptionValueLayout(spacing: spacing).lines(width: bounds.width, subviews: subviews) {
            // space-between: the free space shared between the parts of the line.
            let between = line.indices.count > 1 ? (bounds.width - line.width) / CGFloat(line.indices.count - 1) : 0
            var x = bounds.minX
            for (index, size) in zip(line.indices, line.sizes) {
                subviews[index].place(at: CGPoint(x: x, y: y + (line.height - size.height) / 2), proposal: ProposedViewSize(size))
                x += size.width + spacing + between
            }
            y += line.height + spacing
        }
    }
}

/// The 1 pt `color.border.subtle` rule above every item but the first, in the gap the list leaves
/// between items.
struct QeetrixCheckListRule: View {
    var body: some View {
        GeometryReader { proxy in
            // Below the top by more than half the rule: not the first item.
            if proxy.frame(in: .named(QeetrixCheckListMetrics.space)).minY > QeetrixBorderWidth.default * 0.5 {
                Rectangle()
                    .fill(QeetrixColor.borderSubtle)
                    .frame(width: proxy.size.width, height: QeetrixBorderWidth.default)
                    .offset(y: -QeetrixBorderWidth.default)
            }
        }
        .accessibilityHidden(true)
    }
}

/// check-list.css's lengths, and the list's names.
enum QeetrixCheckListMetrics {
    /// CSS's root font size; scaled with Dynamic Type where it is used.
    static let rem: CGFloat = 16
    /// `.qx-check-item { min-block-size: 3rem }`.
    static let minimumHeight: CGFloat = 3
    /// The coordinate space in which an item finds whether it is the first.
    static let space = "qeetrix.check-list"
}

private struct QeetrixIsInCheckListKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// Whether a ``QeetrixCheckItem`` is in a ``QeetrixCheckList``, which rules between its items.
    var qeetrixIsInCheckList: Bool {
        get { self[QeetrixIsInCheckListKey.self] }
        set { self[QeetrixIsInCheckListKey.self] = newValue }
    }
}
