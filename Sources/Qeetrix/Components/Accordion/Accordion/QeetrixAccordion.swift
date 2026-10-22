import SwiftUI

/// Sections whose headers show and hide their content — the web's `Accordion`, built from native
/// `DisclosureGroup`s.
///
/// ```swift
/// QeetrixAccordion {
///     QeetrixAccordionItem("Billing", description: Text("Invoices and payment method"), icon: .fileText) {
///         BillingSettings()
///     }
///     QeetrixAccordionItem("Notifications", icon: .bell) {
///         NotificationSettings()
///     }
/// }
/// ```
///
/// The container rules between its items, as the web's items do (`border-b … last:border-b-0`), and
/// styles every `DisclosureGroup` inside it with ``QeetrixDisclosureGroupStyle`` — your own groups too.
///
/// Each item keeps its own expansion: several can be open at once. For one-at-a-time, give each item an
/// `isExpanded` binding derived from one optional value you own:
///
/// ```swift
/// @State private var open: Section? = .billing
///
/// QeetrixAccordionItem("Billing", isExpanded: Binding(
///     get: { open == .billing }, set: { open = $0 ? .billing : nil })) { … }
/// ```
///
/// Use it inside a `ScrollView`, a card or a sheet. In a `List`, put a `DisclosureGroup` in a row and
/// style it with `.disclosureGroupStyle(.qeetrix)`: the list draws the separators.
public struct QeetrixAccordion<Content: View>: View {
    let content: Content

    /// - Parameter content: The ``QeetrixAccordionItem``s or `DisclosureGroup`s.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)  // w-full
        .disclosureGroupStyle(.qeetrix)
        .qeetrixRules(QeetrixColor.borderDefault)  // --qx-component-accordion-divider
    }
}

/// One section of an accordion: a header with a title, an optional description and icon, and content
/// it shows and hides. A `DisclosureGroup` in ``QeetrixDisclosureGroupStyle``.
public struct QeetrixAccordionItem<Content: View>: View {
    let title: Text
    let description: Text?
    let icon: QeetrixIconName?
    let isExpanded: Binding<Bool>?
    let content: Content

    /// An item with a localised title.
    ///
    /// - Parameters:
    ///   - titleKey: The header's title, looked up in the main bundle.
    ///   - description: A line under the title, muted.
    ///   - icon: An icon before the title, decorative.
    ///   - isExpanded: Whether the content shows. Without one, the item keeps its own state, collapsed at
    ///     first.
    ///   - content: What the header shows and hides.
    public init(
        _ titleKey: LocalizedStringKey, description: Text? = nil, icon: QeetrixIconName? = nil, isExpanded: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(title: Text(titleKey), description: description, icon: icon, isExpanded: isExpanded, content: content)
    }

    /// An item with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, description: Text? = nil, icon: QeetrixIconName? = nil, isExpanded: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(title: Text(title), description: description, icon: icon, isExpanded: isExpanded, content: content)
    }

    /// An item with a `Text` title.
    public init(
        title: Text, description: Text? = nil, icon: QeetrixIconName? = nil, isExpanded: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.isExpanded = isExpanded
        self.content = content()
    }

    public var body: some View {
        Group {
            if let isExpanded {
                DisclosureGroup(isExpanded: isExpanded) {
                    content
                } label: {
                    header
                }
            } else {
                DisclosureGroup {
                    content
                } label: {
                    header
                }
            }
        }
        .disclosureGroupStyle(.qeetrix)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: QeetrixWebScale.spacing(2)) {
            if let icon {
                QeetrixIcon(icon, size: QeetrixIconSize(QeetrixWebScale.spacing(4)))  // [&_svg]:size-4
                    .foregroundStyle(QeetrixColor.textTertiary)
            }
            VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(0.5)) {
                title
                if let description {
                    description
                        .qeetrixType(QeetrixAccordionMetrics.descriptionType)
                        .foregroundStyle(QeetrixColor.textTertiary)
                }
            }
        }
    }
}

/// The Qeetrix look for any `DisclosureGroup`: a full-width header in `text-sm` medium with a chevron at
/// the trailing end that turns when the content opens, and the content below it in primary `text-sm` —
/// the web's `AccordionTrigger` and `AccordionContent`.
///
/// ```swift
/// DisclosureGroup("Advanced", isExpanded: $showsAdvanced) { AdvancedSettings() }
///     .disclosureGroupStyle(.qeetrix)
/// ```
///
/// The header is one button for VoiceOver, a heading, with "Expanded" or "Collapsed" as its value. The
/// content opens over the accordion's 200 ms, or at once with Reduce Motion on.
public struct QeetrixDisclosureGroupStyle: DisclosureGroupStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixDisclosureBody(configuration: configuration)
    }
}

extension DisclosureGroupStyle where Self == QeetrixDisclosureGroupStyle {
    /// The Qeetrix disclosure style: see ``QeetrixDisclosureGroupStyle``.
    public static var qeetrix: QeetrixDisclosureGroupStyle { QeetrixDisclosureGroupStyle() }
}

struct QeetrixDisclosureBody: View {
    let configuration: DisclosureGroupStyleConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false

    var body: some View {
        let isExpanded = configuration.isExpanded
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(QeetrixMotion.animation(.standard, QeetrixAccordionTokens.duration, reduceMotion: reduceMotion)) {
                    configuration.isExpanded.toggle()
                }
            } label: {
                // items-start: a wrapping label keeps the chevron on its first line.
                HStack(alignment: .top, spacing: QeetrixWebScale.spacing(4)) {  // gap-4
                    configuration.label
                        .qeetrixType(QeetrixAccordionMetrics.triggerType)
                        .foregroundStyle(QeetrixColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    QeetrixIcon(.chevronDown, size: QeetrixIconSize(QeetrixWebScale.spacing(4)))  // size-4
                        .foregroundStyle(isExpanded || isHovered ? QeetrixColor.textPrimary : QeetrixColor.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .padding(.top, QeetrixWebScale.spacing(0.5))  // mt-0.5
                }
                .padding(.vertical, QeetrixAccordionTokens.triggerPaddingBlock)
                .frame(minHeight: QeetrixAccessibility.minimumTouchTarget)
                .contentShape(Rectangle())
            }
            .buttonStyle(QeetrixPlainControlStyle())
            .opacity(isEnabled ? 1 : QeetrixOpacity.disabled)
            .onHover { isHovered = $0 }
            .accessibilityValue(isExpanded ? QeetrixStrings.expanded : QeetrixStrings.collapsed)
            .accessibilityAddTraits(.isHeader)

            if isExpanded {
                configuration.content
                    .qeetrixType(QeetrixAccordionMetrics.contentType)  // text-sm text-foreground
                    .foregroundStyle(QeetrixColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, QeetrixWebScale.spacing(4))  // pb-4
                    .transition(.opacity)
                    // Nested disclosures rule among themselves, not across this accordion.
                    .transformPreference(QeetrixRuledItemsKey.self) { $0 = [] }
            }
        }
        .clipped()
        .qeetrixRuledItem()
    }
}

enum QeetrixAccordionMetrics {
    /// `text-sm font-medium text-foreground`.
    static let triggerType = QeetrixComponentType.ui(QeetrixWebScale.textSM, .medium, scalesLike: .subheadline)
    /// `text-sm text-foreground`: a panel holds content, so it is primary, not muted.
    static let contentType = QeetrixComponentType.sans(QeetrixWebScale.textSM, .regular, scalesLike: .subheadline)
    /// A header's description: `text-sm text-muted-foreground`.
    static let descriptionType = QeetrixComponentType.sans(QeetrixWebScale.textSM, .regular, scalesLike: .subheadline)
}
