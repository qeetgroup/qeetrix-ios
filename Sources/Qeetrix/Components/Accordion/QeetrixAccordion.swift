import SwiftUI

/// Stacked sections that show and hide, ruled like every surface — `@qeetrix/react`'s Accordion. Put
/// ``QeetrixAccordionItem``s in it: a 1 pt `color.border.subtle` rule runs above each and below the
/// last.
///
/// ```swift
/// @State private var open: Section? = .tax
///
/// QeetrixAccordion(expanded: $open) {
///     QeetrixAccordionItem("Tax settings", value: Section.tax) { QeetrixText("GST is added at 18%.") }
///     QeetrixAccordionItem("Invoice numbering", value: Section.numbering) { QeetrixText("INV-YYYY-NNNN") }
/// }
/// ```
///
/// What is open is yours. With a `Binding<Value?>`, one section is open at a time: opening one closes
/// the other, and `nil` means all are closed. With a `Binding<Set<Value>>` — the web's `multiple` —
/// any number are. Without a binding, each item brings its own `isExpanded`. Sections are found by
/// their values, which must be of the binding's type. `disabled(_:)` on the accordion disables every
/// section.
public struct QeetrixAccordion<Content: View>: View {
    let context: QeetrixAccordionContext
    let content: Content

    /// Sections that each bring their own `isExpanded` binding.
    public init(@ViewBuilder content: () -> Content) {
        context = QeetrixAccordionContext(isExpanded: nil, setExpanded: nil)
        self.content = content()
    }

    /// One section open at a time: `expanded` is the open section's value, `nil` when all are closed.
    public init<Value: Hashable>(expanded: Binding<Value?>, @ViewBuilder content: () -> Content) {
        context = QeetrixAccordionContext(
            isExpanded: { key in (key.base as? Value).map { $0 == expanded.wrappedValue } ?? false },
            setExpanded: { key, isExpanded in
                guard let value = key.base as? Value else { return }
                expanded.wrappedValue = QeetrixAccordionExpansion.single(expanded.wrappedValue, value, isExpanded: isExpanded)
            })
        self.content = content()
    }

    /// Any number of sections open: `expanded` holds the open sections' values.
    public init<Value: Hashable>(expanded: Binding<Set<Value>>, @ViewBuilder content: () -> Content) {
        context = QeetrixAccordionContext(
            isExpanded: { key in (key.base as? Value).map { expanded.wrappedValue.contains($0) } ?? false },
            setExpanded: { key, isExpanded in
                guard let value = key.base as? Value else { return }
                expanded.wrappedValue = QeetrixAccordionExpansion.multiple(expanded.wrappedValue, value, isExpanded: isExpanded)
            })
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
            // accordion.css `.qx-accordion { border-block-end }`.
            QeetrixAccordionRule()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .environment(\.qeetrixAccordion, context)
    }
}

/// One section that shows and hides, as `@qeetrix/react`'s AccordionItem: a full-width trigger with
/// its title and a turning chevron, then the content.
///
/// ```swift
/// QeetrixAccordionItem("Advanced options", isExpanded: $showsAdvanced) {
///     QeetrixSwitch("Retry failed webhooks", isOn: $retries)
/// }
/// ```
///
/// Inside a ``QeetrixAccordion`` with a binding, give it a `value`; anywhere else, an `isExpanded`
/// binding — on its own it is a single collapsible section, ruled above and below. The trigger is at
/// least 44 pt tall, the title in `title.sm` and a 16 pt sharp `chevron-down` in `color.icon.subtle`
/// that turns over `motion.duration.normal` as the content opens by height; nothing moves under
/// Reduce Motion. The content is set in `body.md`, with `space.inset.lg` below it. VoiceOver reads the
/// trigger as a heading of `headingLevel` and a button, expanded or collapsed. `disabled(_:)` dims the
/// title and the chevron, and the section can't be toggled.
public struct QeetrixAccordionItem<Content: View>: View {
    let title: Text
    let expansion: Expansion
    let headingLevel: Int
    let content: Content
    @Environment(\.qeetrixAccordion) private var accordion
    /// For a section with a value outside an accordion that owns a binding.
    @State private var isExpandedLocally = false

    enum Expansion {
        case binding(Binding<Bool>)
        case value(AnyHashable)
    }

    /// A section with its own `isExpanded` binding and a localised title.
    public init(
        _ titleKey: LocalizedStringKey, isExpanded: Binding<Bool>, headingLevel: Int = 3, @ViewBuilder content: () -> Content
    ) {
        self.init(title: Text(titleKey), expansion: .binding(isExpanded), headingLevel: headingLevel, content: content)
    }

    /// A section with its own `isExpanded` binding and a title shown as given.
    public init<S: StringProtocol>(_ title: S, isExpanded: Binding<Bool>, headingLevel: Int = 3, @ViewBuilder content: () -> Content) {
        self.init(title: Text(title), expansion: .binding(isExpanded), headingLevel: headingLevel, content: content)
    }

    /// A section with its own `isExpanded` binding and a `Text` title.
    public init(title: Text, isExpanded: Binding<Bool>, headingLevel: Int = 3, @ViewBuilder content: () -> Content) {
        self.init(title: title, expansion: .binding(isExpanded), headingLevel: headingLevel, content: content)
    }

    /// A section of a ``QeetrixAccordion`` that owns which are open, with a localised title.
    public init<Value: Hashable>(
        _ titleKey: LocalizedStringKey, value: Value, headingLevel: Int = 3, @ViewBuilder content: () -> Content
    ) {
        self.init(title: Text(titleKey), expansion: .value(AnyHashable(value)), headingLevel: headingLevel, content: content)
    }

    /// A section of a ``QeetrixAccordion`` that owns which are open, with a title shown as given.
    public init<S: StringProtocol, Value: Hashable>(_ title: S, value: Value, headingLevel: Int = 3, @ViewBuilder content: () -> Content) {
        self.init(title: Text(title), expansion: .value(AnyHashable(value)), headingLevel: headingLevel, content: content)
    }

    /// A section of a ``QeetrixAccordion`` that owns which are open, with a `Text` title.
    public init<Value: Hashable>(title: Text, value: Value, headingLevel: Int = 3, @ViewBuilder content: () -> Content) {
        self.init(title: title, expansion: .value(AnyHashable(value)), headingLevel: headingLevel, content: content)
    }

    private init(title: Text, expansion: Expansion, headingLevel: Int, content: () -> Content) {
        self.title = title
        self.expansion = expansion
        self.headingLevel = headingLevel
        self.content = content()
    }

    public var body: some View {
        DisclosureGroup(isExpanded: isExpanded) {
            content
        } label: {
            title
        }
        .disclosureGroupStyle(QeetrixAccordionDisclosureGroupStyle(headingLevel: headingLevel))
    }

    private var isExpanded: Binding<Bool> {
        switch expansion {
        case let .binding(binding):
            return binding
        case let .value(value):
            guard let accordion, let get = accordion.isExpanded, let set = accordion.setExpanded else { return $isExpandedLocally }
            return Binding(get: { get(value) }, set: { set(value, $0) })
        }
    }
}

/// The Qeetrix accordion section's look for any `DisclosureGroup`: the trigger with its title and a
/// turning chevron, then the content, ruled above — and below too, outside a ``QeetrixAccordion``.
///
/// ```swift
/// DisclosureGroup("Retry policy", isExpanded: $showsRetries) {
///     QeetrixText("Three attempts, a minute apart.")
/// }
/// .disclosureGroupStyle(.qeetrixAccordion())
/// ```
public struct QeetrixAccordionDisclosureGroupStyle: DisclosureGroupStyle {
    let headingLevel: Int

    /// The trigger is read as a heading of `headingLevel` — 3 by default, as on the web.
    public init(headingLevel: Int = 3) {
        self.headingLevel = headingLevel
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixAccordionItemBody(configuration: configuration, headingLevel: headingLevel)
    }
}

extension DisclosureGroupStyle where Self == QeetrixAccordionDisclosureGroupStyle {
    /// The Qeetrix accordion section style.
    public static func qeetrixAccordion(headingLevel: Int = 3) -> QeetrixAccordionDisclosureGroupStyle {
        QeetrixAccordionDisclosureGroupStyle(headingLevel: headingLevel)
    }
}

struct QeetrixAccordionItemBody: View {
    let configuration: DisclosureGroupStyleConfiguration
    let headingLevel: Int
    @Environment(\.qeetrixAccordion) private var accordion

    var body: some View {
        let isExpanded = configuration.isExpanded
        VStack(alignment: .leading, spacing: 0) {
            // accordion.css `.qx-accordion-item { border-block-start }`.
            QeetrixAccordionRule()
            Button {
                configuration.isExpanded.toggle()
            } label: {
                configuration.label
            }
            .buttonStyle(QeetrixAccordionTriggerStyle(isExpanded: isExpanded))
            .accessibilityValue(isExpanded ? QeetrixAccordionStrings.expanded : QeetrixAccordionStrings.collapsed)
            .accessibilityAddTraits(.isHeader)
            .accessibilityHeading(QeetrixHeading.accessibilityLevel(headingLevel))
            // accordion.css `.qx-accordion-panel`: the content opens by height, clipped, as on the web.
            // Closed, it stays laid out at no height, hidden from VoiceOver and touch.
            configuration.content
                .qeetrixTypeEnvironment(QeetrixTypeSpec(.bodyMd))
                .foregroundStyle(QeetrixColor.textDefault)
                .padding(.bottom, QeetrixSpace.insetLg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: isExpanded ? nil : 0, alignment: .top)
                .clipped()
                .accessibilityHidden(!isExpanded)
                .allowsHitTesting(isExpanded)
            if accordion == nil {
                // On its own, a section is ruled below as well.
                QeetrixAccordionRule()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .qeetrixAnimation(.standard, .normal, value: isExpanded)
    }
}

/// The trigger (accordion.css `.qx-accordion-trigger`): the title and the chevron `space.gap.md`
/// apart, full width, at least `size.control.lg` tall and here at least 44 pt, because triggers stack
/// flush and an extended target would overlap the next one.
private struct QeetrixAccordionTriggerStyle: ButtonStyle {
    let isExpanded: Bool

    func makeBody(configuration: Configuration) -> some View {
        QeetrixAccordionTrigger(label: configuration.label, isExpanded: isExpanded)
    }
}

private struct QeetrixAccordionTrigger<Label: View>: View {
    let label: Label
    let isExpanded: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.qeetrixDensity) private var density

    var body: some View {
        HStack(spacing: QeetrixSpace.gapMd) {
            label
                .qeetrixType(QeetrixAccordionMetrics.titleType)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(isEnabled ? QeetrixColor.textDefault : QeetrixColor.textDisabled)
            QeetrixIcon(.chevronDown, size: .sm, shape: .sharp)
                // `[data-disabled] > .qx-accordion-icon`: `icon.disabled` with the text (QTRX-167).
                .foregroundStyle(QeetrixAccordionMetrics.chevronColor(isEnabled: isEnabled))
                // `[data-panel-open] > .qx-accordion-icon { rotate: 180deg }`.
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
        }
        .qeetrixControlBlockSize(QeetrixAccordionMetrics.triggerHeight(density), type: QeetrixAccordionMetrics.titleType)
        .contentShape(Rectangle())
        // `:focus-visible`: the Ember frame inside the trigger (outline-offset −focus.ring.width).
        .overlay {
            if isFocused {
                Rectangle().strokeBorder(QeetrixColor.borderFocus, lineWidth: QeetrixFocus.ringWidth).accessibilityHidden(true)
            }
        }
    }
}

enum QeetrixAccordionMetrics {
    /// `title.sm`, in the heading letter style its token names.
    static let titleType = QeetrixComponentType.role(.titleSm)

    /// `min-block-size: size.control.lg`, and at least the 44 pt touch target.
    static func triggerHeight(_ density: QeetrixDensity) -> CGFloat {
        max(density.sizeControlLg, QeetrixAccessibility.minimumTouchTarget)
    }

    static func chevronColor(isEnabled: Bool) -> QeetrixColor {
        isEnabled ? .iconSubtle : .iconDisabled
    }
}

/// The 1 pt `color.border.subtle` rule between sections.
struct QeetrixAccordionRule: View {
    var body: some View {
        Rectangle()
            .fill(QeetrixColor.borderSubtle)
            .frame(height: QeetrixBorderWidth.default)
            .accessibilityHidden(true)
    }
}

/// The open sections after one opens or closes.
enum QeetrixAccordionExpansion {
    /// One at a time: opening a section replaces the open one; closing the open one leaves none.
    static func single<Value: Hashable>(_ expanded: Value?, _ value: Value, isExpanded: Bool) -> Value? {
        if isExpanded { return value }
        return expanded == value ? nil : expanded
    }

    /// Any number: the section joins or leaves the set.
    static func multiple<Value: Hashable>(_ expanded: Set<Value>, _ value: Value, isExpanded: Bool) -> Set<Value> {
        var expanded = expanded
        if isExpanded { expanded.insert(value) } else { expanded.remove(value) }
        return expanded
    }
}

/// How an accordion's sections reach the binding it owns. Without one (`nil` closures), each section
/// brings its own.
struct QeetrixAccordionContext: Sendable {
    let isExpanded: (@MainActor @Sendable (AnyHashable) -> Bool)?
    let setExpanded: (@MainActor @Sendable (AnyHashable, Bool) -> Void)?
}

private struct QeetrixAccordionContextKey: EnvironmentKey {
    static let defaultValue: QeetrixAccordionContext? = nil
}

extension EnvironmentValues {
    /// The accordion the view sits in, if any.
    var qeetrixAccordion: QeetrixAccordionContext? {
        get { self[QeetrixAccordionContextKey.self] }
        set { self[QeetrixAccordionContextKey.self] = newValue }
    }
}

/// The trigger's state for VoiceOver. iOS only: the web's `aria-expanded` is read by the browser.
enum QeetrixAccordionStrings {
    /// "Expanded".
    static var expanded: Text {
        Text(verbatim: String(localized: "qeetrix.accordion.expanded", defaultValue: "Expanded", bundle: .module))
    }

    /// "Collapsed".
    static var collapsed: Text {
        Text(verbatim: String(localized: "qeetrix.accordion.collapsed", defaultValue: "Collapsed", bundle: .module))
    }
}
