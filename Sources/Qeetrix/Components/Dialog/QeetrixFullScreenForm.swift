import SwiftUI

extension View {
    /// Presents a create or edit flow while `isPresented` is true: over the whole screen on a phone, as a
    /// form sheet on a tablet. Put a ``QeetrixFullScreenForm`` in it.
    ///
    /// ```swift
    /// .qeetrixFullScreenForm(isPresented: $isAdding) {
    ///     QeetrixFullScreenForm("New contact", confirm: QeetrixScreenAction("Save") { save() }, hasChanges: draft != Contact()) {
    ///         QeetrixTextField("Name", text: $draft.name)
    ///         QeetrixTextField("Email", text: $draft.email)
    ///     }
    /// }
    /// ```
    ///
    /// At compact width it is the system's full-screen cover, which no swipe dismisses; at regular width
    /// the system sheet, sized for a form from iOS 18 (`presentationSizing(.form)`) and on the overlay
    /// surface with 4 pt corners. `isPresented` is yours and becomes `false` however the form closes. If
    /// the width class changes while the form is open — an iPad entering Split View — it moves to the
    /// other presentation, so keep the draft in your state, not the form's.
    public func qeetrixFullScreenForm<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(QeetrixFullScreenFormPresentation(isPresented: isPresented, onDismiss: onDismiss, form: content))
    }

    /// Presents a create or edit flow for `item` while it is not `nil`, and sets it back to `nil` when the
    /// form closes.
    public func qeetrixFullScreenForm<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        modifier(QeetrixFullScreenFormItemPresentation(item: item, onDismiss: onDismiss, form: content))
    }
}

/// How a full-screen form is presented: a cover at compact width, a form sheet at regular width.
enum QeetrixFullScreenFormStyle: Equatable {
    case fullScreen
    case formSheet

    init(_ horizontalSizeClass: UserInterfaceSizeClass?) {
        self = horizontalSizeClass == .regular ? .formSheet : .fullScreen
    }
}

struct QeetrixFullScreenFormPresentation<Form: View>: ViewModifier {
    let isPresented: Binding<Bool>
    let onDismiss: (() -> Void)?
    let form: () -> Form
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    func body(content: Content) -> some View {
        let style = QeetrixFullScreenFormStyle(horizontalSizeClass)
        #if os(iOS)
            // One presentation is live at a time; the other's binding stays false.
            content
                .fullScreenCover(isPresented: style == .fullScreen ? isPresented : .constant(false), onDismiss: onDismiss) {
                    form().modifier(QeetrixFullScreenFormSurface(style: .fullScreen))
                }
                .sheet(isPresented: style == .formSheet ? isPresented : .constant(false), onDismiss: onDismiss) {
                    form().modifier(QeetrixFullScreenFormSurface(style: .formSheet))
                }
        #else
            content.sheet(isPresented: isPresented, onDismiss: onDismiss) {
                form().modifier(QeetrixFullScreenFormSurface(style: .formSheet))
            }
        #endif
    }
}

struct QeetrixFullScreenFormItemPresentation<Item: Identifiable, Form: View>: ViewModifier {
    let item: Binding<Item?>
    let onDismiss: (() -> Void)?
    let form: (Item) -> Form
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    func body(content: Content) -> some View {
        let style = QeetrixFullScreenFormStyle(horizontalSizeClass)
        #if os(iOS)
            content
                .fullScreenCover(item: style == .fullScreen ? item : .constant(nil), onDismiss: onDismiss) { presented in
                    form(presented).modifier(QeetrixFullScreenFormSurface(style: .fullScreen))
                }
                .sheet(item: style == .formSheet ? item : .constant(nil), onDismiss: onDismiss) { presented in
                    form(presented).modifier(QeetrixFullScreenFormSurface(style: .formSheet))
                }
        #else
            content.sheet(item: item, onDismiss: onDismiss) { presented in
                form(presented).modifier(QeetrixFullScreenFormSurface(style: .formSheet))
            }
        #endif
    }
}

/// The presentation's surface: the form sheet takes the overlay surface, 4 pt corners and, from iOS 18,
/// the system's form size; the cover is the form's own surface edge to edge.
struct QeetrixFullScreenFormSurface: ViewModifier {
    let style: QeetrixFullScreenFormStyle

    func body(content: Content) -> some View {
        switch style {
        case .fullScreen:
            content
        case .formSheet:
            let sheet =
                content
                .presentationBackground(QeetrixColor.surfaceOverlay)
                .presentationCornerRadius(QeetrixRadius.modal)
                .presentationDragIndicator(.hidden)
            if #available(iOS 18, macOS 15, *) {
                sheet.presentationSizing(.form)
            } else {
                sheet
            }
        }
    }
}

/// A modal screen for creating or editing something — `@qeetrix/react`'s Dialog at `size="fullscreen"`,
/// with Material's full-screen dialog bar: the Dialog's 3 pt Ember line, then a bar with Close at the
/// start, the title (`title.md`, a heading) and the confirming action at the end, and the fields below,
/// which scroll.
///
/// ```swift
/// QeetrixFullScreenForm(
///     "Edit contact", confirm: QeetrixScreenAction("Save", isLoading: isSaving) { save() }, hasChanges: hasChanges
/// ) {
///     QeetrixTextField("Name", text: $draft.name)
///     QeetrixTextField("Email", text: $draft.email)
/// }
/// ```
///
/// Present it with `qeetrixFullScreenForm(isPresented:onDismiss:content:)`. The surface is
/// `color.surface.overlay`; the bar is the app chrome's height (`size.control.lg` + 16 pt) and ends on a
/// 1 pt `color.border.subtle` rule; the fields sit `space.form.gap` apart, on the phone's 16 pt gutter
/// (24 pt in a form sheet, the Dialog's padding). Close is a neutral ghost ``QeetrixIconButton`` named
/// "Close"; the confirming action is a solid `md` ``QeetrixButton``. A title too long for the bar moves
/// onto its own line under it, and wraps.
///
/// - **Confirming.** The action runs as given; close the form yourself once it has succeeded, so a form
///   that fails validation stays open with its errors.
/// - **Closing.** With `hasChanges` false, Close dismisses the form. With unsaved changes it asks first,
///   in a ``QeetrixConfirmationDialog`` ("Discard your changes?": "Discard changes" or "Keep editing"),
///   and a swipe can't dismiss the form sheet. `discardTitle` replaces the question; `onClose` replaces
///   what Close does altogether. Escape on a hardware keyboard and VoiceOver's escape gesture are Close.
/// - **The keyboard.** The fields scroll above it, a focused field is kept in view, and dragging the
///   fields down puts the keyboard away.
public struct QeetrixFullScreenForm<Content: View>: View {
    let title: Text
    let confirm: QeetrixScreenAction
    let hasChanges: Bool
    let discardTitle: Text?
    let onClose: (@MainActor () -> Void)?
    let content: Content
    @State private var discard: QeetrixConfirmationDialog?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.qeetrixDensity) private var density

    /// A form with a localised title.
    public init(
        _ titleKey: LocalizedStringKey, confirm: QeetrixScreenAction, hasChanges: Bool = false, discardTitle: Text? = nil,
        onClose: (@MainActor () -> Void)? = nil, @ViewBuilder content: () -> Content
    ) {
        self.init(
            title: Text(titleKey), confirm: confirm, hasChanges: hasChanges, discardTitle: discardTitle, onClose: onClose, content: content)
    }

    /// A form with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, confirm: QeetrixScreenAction, hasChanges: Bool = false, discardTitle: Text? = nil,
        onClose: (@MainActor () -> Void)? = nil, @ViewBuilder content: () -> Content
    ) {
        self.init(
            title: Text(title), confirm: confirm, hasChanges: hasChanges, discardTitle: discardTitle, onClose: onClose, content: content)
    }

    /// A form with a `Text` title.
    ///
    /// - Parameters:
    ///   - title: What the form creates or edits ("New contact", "Edit address").
    ///   - confirm: The confirming action, a verb ("Save", "Create"). Its emphasis is always `solid`.
    ///   - hasChanges: Whether closing now would throw work away: Close then asks first, and a swipe
    ///     can't dismiss the form sheet.
    ///   - discardTitle: The question Close asks, in place of "Discard your changes?".
    ///   - onClose: What Close does, in place of dismissing (and asking first).
    ///   - content: The fields.
    public init(
        title: Text, confirm: QeetrixScreenAction, hasChanges: Bool = false, discardTitle: Text? = nil,
        onClose: (@MainActor () -> Void)? = nil, @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.confirm = confirm
        self.hasChanges = hasChanges
        self.discardTitle = discardTitle
        self.onClose = onClose
        self.content = content()
    }

    public var body: some View {
        let gutter = QeetrixFullScreenFormMetrics.gutter(isCompact: horizontalSizeClass != .regular)
        ScrollView {
            VStack(alignment: .leading, spacing: density.spaceFormGap) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(gutter)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        // The bar stays put and the fields scroll beneath it, so it carries the surface, up under the
        // status bar.
        .safeAreaInset(edge: .top, spacing: 0) {
            QeetrixFullScreenFormBar(title: title, confirm: confirm, gutter: gutter, discard: $discard, close: close)
        }
        .background(QeetrixColor.surfaceOverlay)
        .foregroundStyle(QeetrixColor.textDefault)
        .qeetrixTypeEnvironment(QeetrixTypeSpec(.bodyMd))
        .interactiveDismissDisabled(hasChanges)
        .accessibilityAction(.escape, close)
    }

    /// Close: the app's `onClose`, or straight out without changes, or ask first.
    private func close() {
        switch QeetrixFullScreenFormMetrics.closing(hasChanges: hasChanges, hasOnClose: onClose != nil) {
        case .callOnClose:
            onClose?()
        case .dismiss:
            dismiss()
        case .confirmDiscard:
            let dismiss = dismiss
            discard = QeetrixConfirmationDialog(
                title: discardTitle ?? QeetrixFullScreenFormStrings.discardTitle,
                actions: [
                    QeetrixDialogAction(title: QeetrixFullScreenFormStrings.discard, role: .destructive) { dismiss() },
                    QeetrixDialogAction(title: QeetrixFullScreenFormStrings.keepEditing, role: .cancel),
                ])
        }
    }
}

/// The bar: the 3 pt Ember line, then Close, the title and the confirming action, then the rule.
struct QeetrixFullScreenFormBar: View {
    let title: Text
    let confirm: QeetrixScreenAction
    let gutter: CGFloat
    @Binding var discard: QeetrixConfirmationDialog?
    let close: @MainActor () -> Void
    @Environment(\.qeetrixDensity) private var density

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(QeetrixDialogIntent.standard.color)
                .frame(height: QeetrixBorderWidth.accent)
                .accessibilityHidden(true)
            // One row while the title fits on a line; else the title takes its own line under the buttons.
            QeetrixFullScreenFormBarLayout(titleInset: QeetrixFullScreenFormMetrics.closeInset(density)) {
                closeButton
                heading
                confirmButton
            }
            .padding(.leading, max(0, gutter - QeetrixFullScreenFormMetrics.closeInset(density)))
            .padding(.trailing, gutter)
            .padding(.vertical, QeetrixSpace.gapSm)
            .frame(minHeight: QeetrixFullScreenFormMetrics.barHeight(density))
            QeetrixSheetRule()
        }
        .background(QeetrixColor.surfaceOverlay, ignoresSafeAreaEdges: .top)
    }

    private var heading: some View {
        title
            .qeetrixTextStyle(.titleMd)
            .foregroundStyle(QeetrixColor.textDefault)
            .multilineTextAlignment(.leading)
            .accessibilityAddTraits(.isHeader)
    }

    private var closeButton: some View {
        QeetrixIconButton(.x, label: QeetrixStrings.close, tone: .neutral, action: close)
            .keyboardShortcut(.cancelAction)
            .qeetrixConfirmationDialog($discard)
    }

    private var confirmButton: some View {
        confirm.button(.solid, size: .md, isFullWidth: false)
    }
}

/// The bar's three parts — Close, the title, the confirming action — in one row while the title fits on
/// a line between the buttons (`space.gap.sm` apart, centred on the row); otherwise the buttons share the
/// first row and the title takes the line under them, its start on the fields' gutter, wrapping. One copy
/// of each part either way, so VoiceOver reads Close, the title, then the action, and Close keeps its
/// keyboard shortcut and its confirmation.
struct QeetrixFullScreenFormBarLayout: Layout {
    /// Where the title starts in the two-row arrangement: Close's icon, not its edge.
    let titleInset: CGFloat
    var spacing = QeetrixSpace.gapSm
    var rowSpacing = QeetrixSpace.gapXs

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(width: proposal.width, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for (subview, frame) in zip(subviews, arrange(width: bounds.width, subviews: subviews).frames) {
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }

    /// Whether the title, at `titleWidth` on one line, fits between the buttons in `width`.
    static func fitsOneRow(width: CGFloat, close: CGFloat, title titleWidth: CGFloat, confirm: CGFloat, spacing: CGFloat) -> Bool {
        titleWidth <= width - close - confirm - 2 * spacing
    }

    private func arrange(width proposed: CGFloat?, subviews: Subviews) -> (frames: [CGRect], size: CGSize) {
        guard subviews.count == 3 else { return (subviews.map { _ in .zero }, .zero) }
        let close = subviews[0].sizeThatFits(.unspecified)
        let ideal = subviews[1].sizeThatFits(.unspecified)
        let confirm = subviews[2].sizeThatFits(.unspecified)
        let width = proposed.flatMap { $0.isFinite ? $0 : nil } ?? close.width + ideal.width + confirm.width + 2 * spacing
        if Self.fitsOneRow(width: width, close: close.width, title: ideal.width, confirm: confirm.width, spacing: spacing) {
            let room = max(0, width - close.width - confirm.width - 2 * spacing)
            let title = subviews[1].sizeThatFits(ProposedViewSize(width: room, height: nil))
            let height = max(close.height, title.height, confirm.height)
            return (
                [
                    CGRect(x: 0, y: (height - close.height) / 2, width: close.width, height: close.height),
                    CGRect(x: close.width + spacing, y: (height - title.height) / 2, width: room, height: title.height),
                    CGRect(x: width - confirm.width, y: (height - confirm.height) / 2, width: confirm.width, height: confirm.height),
                ],
                CGSize(width: width, height: height)
            )
        }
        let row = max(close.height, confirm.height)
        let titleWidth = max(0, width - titleInset)
        let title = subviews[1].sizeThatFits(ProposedViewSize(width: titleWidth, height: nil))
        return (
            [
                CGRect(x: 0, y: (row - close.height) / 2, width: close.width, height: close.height),
                CGRect(x: titleInset, y: row + rowSpacing, width: titleWidth, height: title.height),
                CGRect(x: width - confirm.width, y: (row - confirm.height) / 2, width: confirm.width, height: confirm.height),
            ],
            CGSize(width: width, height: row + rowSpacing + title.height + rowSpacing)
        )
    }
}

/// The form's metrics and its one decision.
enum QeetrixFullScreenFormMetrics {
    /// What Close does.
    enum Closing: Equatable {
        case callOnClose
        case dismiss
        case confirmDiscard
    }

    static func closing(hasChanges: Bool, hasOnClose: Bool) -> Closing {
        if hasOnClose { return .callOnClose }
        return hasChanges ? .confirmDiscard : .dismiss
    }

    /// The fields' gutter: the phone's `space.inset.lg` (page-header.css below 840 px), or the Dialog's
    /// `space.inset.xl` (dialog.css `.qx-dialog-header`, `.qx-dialog-body`) in a form sheet.
    static func gutter(isCompact: Bool) -> CGFloat {
        isCompact ? QeetrixSpace.insetLg : QeetrixSpace.insetXl
    }

    /// The app chrome's height: app-shell.css `--qx-app-shell-top: calc(size.control.lg + 16px)`.
    static func barHeight(_ density: QeetrixDensity) -> CGFloat {
        density.sizeControlLg + 16
    }

    /// The space between Close's edge and its 16 pt icon, so the icon, not the button, lines up with the
    /// fields' gutter.
    static func closeInset(_ density: QeetrixDensity) -> CGFloat {
        max(0, (density.sizeControlMd - QeetrixButtonStyle.iconSize(for: .md).points) / 2)
    }
}

/// The form's built-in strings. The keys sit beside `Resources/Localization`'s; until a translation adds
/// them, the English defaults here are shown.
enum QeetrixFullScreenFormStrings {
    /// "Discard your changes?" — the question Close asks when there are unsaved changes.
    static var discardTitleString: String {
        String(localized: "qeetrix.full-screen-form.discard-title", defaultValue: "Discard your changes?", bundle: .module)
    }

    /// "Discard changes" — the destructive answer.
    static var discardString: String {
        String(localized: "qeetrix.full-screen-form.discard", defaultValue: "Discard changes", bundle: .module)
    }

    /// "Keep editing" — the cancel answer.
    static var keepEditingString: String {
        String(localized: "qeetrix.full-screen-form.keep-editing", defaultValue: "Keep editing", bundle: .module)
    }

    static var discardTitle: Text { Text(discardTitleString) }
    static var discard: Text { Text(discardString) }
    static var keepEditing: Text { Text(keepEditingString) }
}
