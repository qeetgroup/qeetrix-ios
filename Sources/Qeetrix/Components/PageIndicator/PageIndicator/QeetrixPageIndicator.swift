import SwiftUI

/// Where you are in paged content — onboarding, a carousel — as a row of marks, one per page. iOS
/// only: `@qeetrix/react` has no page indicator, so it is drawn from the design rules.
///
/// ```swift
/// @State private var page = 0
///
/// TabView(selection: $page) {
///     ForEach(slides.indices, id: \.self) { index in
///         SlideView(slide: slides[index]).tag(index)
///     }
/// }
/// .tabViewStyle(.page(indexDisplayMode: .never))
/// QeetrixPageIndicator(page: $page, count: slides.count)
/// ```
///
/// `page` is the current page's index, from 0. Each page is an 8 pt square mark with the small marks'
/// 2 pt corners (design rules §3) in `color.border.strong`, `space.gap.sm` apart; the current page is
/// marked in Ember and three marks wide (§11), so it never rests on colour. The mark slides over
/// `motion.duration.normal`, and jumps under Reduce Motion.
///
/// A tap before the current page moves one page back, after it one page on, as the system's page
/// control does, so each target is half the control — at least 44 pt — rather than an 8 pt mark.
/// VoiceOver reads it as one adjustable element, "Page 2 of 4": swipe up or down to move. `label`
/// names it where a screen has more than one.
public struct QeetrixPageIndicator: View {
    let page: Binding<Int>
    let count: Int
    let label: Text?
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.locale) private var locale

    /// - Parameters:
    ///   - page: The current page's index, from 0.
    ///   - count: How many pages there are.
    ///   - label: What VoiceOver names the indicator, such as "Onboarding".
    public init(page: Binding<Int>, count: Int, label: Text? = nil) {
        self.page = page
        self.count = count
        self.label = label
    }

    public var body: some View {
        let metrics = QeetrixPageIndicatorMetrics.self
        let current = metrics.clamped(page.wrappedValue, count: count)
        if count > 0 {
            HStack(spacing: metrics.gap) {
                ForEach(0..<count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: QeetrixRadius.sm)
                        .fill(metrics.color(isCurrent: index == current, isEnabled: isEnabled))
                        .frame(width: index == current ? metrics.currentWidth : metrics.mark, height: metrics.mark)
                }
            }
            .padding(.horizontal, metrics.padding)
            .frame(minHeight: QeetrixAccessibility.minimumTouchTarget)
            .overlay {
                // The two targets, split at the current mark: back before it, on after it. An HStack,
                // so they follow the reading direction as the marks do.
                HStack(spacing: 0) {
                    Color.clear
                        .frame(width: metrics.split(current: current))
                        .contentShape(Rectangle())
                        .onTapGesture { move(by: -1) }
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { move(by: 1) }
                }
            }
            .qeetrixAnimation(.standard, .normal, value: current)
            .accessibilityElement(children: .ignore)
            .modifier(QeetrixPageIndicatorLabel(label: label))
            .accessibilityValue(Text(verbatim: QeetrixPageIndicatorStrings.value(page: current + 1, count: count, locale: locale)))
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: move(by: 1)
                case .decrement: move(by: -1)
                @unknown default: break
                }
            }
        }
    }

    private func move(by step: Int) {
        guard isEnabled else { return }
        let next = QeetrixPageIndicatorMetrics.page(page.wrappedValue, moved: step, count: count)
        if next != page.wrappedValue { page.wrappedValue = next }
    }
}

private struct QeetrixPageIndicatorLabel: ViewModifier {
    let label: Text?

    func body(content: Content) -> some View {
        if let label {
            content.accessibilityLabel(label)
        } else {
            content
        }
    }
}

/// The marks and the targets. No CSS draws a page indicator, so each length is the design rules':
/// lengths on the 4 pt grid (§6), small marks with 2 pt corners (§3).
enum QeetrixPageIndicatorMetrics {
    /// A page's mark: an 8 pt square.
    static let mark: CGFloat = 8
    /// The current page's mark: three marks wide.
    static let currentWidth: CGFloat = 24
    /// Between marks: `space.gap.sm`.
    static let gap = QeetrixSpace.gapSm
    /// Either side of the marks: `space.inset.lg`, so the back and on targets are at least 44 pt wide
    /// whenever there is a page to move to (16 + one mark and its gap + half the current mark = 44).
    static let padding = QeetrixSpace.insetLg

    /// The current page's index, kept inside the pages.
    static func clamped(_ page: Int, count: Int) -> Int {
        min(max(page, 0), max(count - 1, 0))
    }

    /// The page `step` pages from `page`, kept inside the pages.
    static func page(_ page: Int, moved step: Int, count: Int) -> Int {
        clamped(clamped(page, count: count) + step, count: count)
    }

    /// Where the back target ends: the middle of the current mark, from the reading start.
    static func split(current: Int) -> CGFloat {
        padding + CGFloat(current) * (mark + gap) + currentWidth / 2
    }

    /// The marks' width with their padding.
    static func width(count: Int) -> CGFloat {
        guard count > 0 else { return 0 }
        return 2 * padding + CGFloat(count - 1) * (mark + gap) + currentWidth
    }

    /// Ember for the current page (design rules §4, §11), the 3:1 control border for the others.
    static func color(isCurrent: Bool, isEnabled: Bool) -> QeetrixColor {
        switch (isCurrent, isEnabled) {
        case (true, true): .bgBrandBold
        case (false, true): .borderStrong
        case (true, false): .iconDisabled
        case (false, false): .borderDisabled
        }
    }
}

/// The indicator's value for VoiceOver. iOS only: the web has no page indicator.
enum QeetrixPageIndicatorStrings {
    /// "Page 2 of 4", the numbers in the locale's digits.
    static func value(page: Int, count: Int, locale: Locale) -> String {
        String(localized: "qeetrix.page-indicator.value", defaultValue: "Page \(page) of \(count)", bundle: .module, locale: locale)
    }
}
