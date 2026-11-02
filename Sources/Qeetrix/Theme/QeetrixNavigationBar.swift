import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

/// The background behind a Qeetrix navigation bar.
public enum QeetrixNavigationBarBackground: String, CaseIterable, Sendable {
    /// The system's: transparent at the scroll edge, its material once content scrolls under it.
    case automatic
    /// The Qeetrix canvas colour, always — for a screen whose content should not show through the bar.
    case canvas
}

/// The typeface of a navigation bar's titles.
public enum QeetrixNavigationBarTitle: String, CaseIterable, Sendable {
    /// The system's: iOS draws the titles in its own font.
    case system
    /// Qeet Sans: the large title in `heading.lg`, the inline title in `title.md`, both
    /// `color.text.default` — the large title that collapses into the bar as the screen scrolls.
    case qeetrix
}

extension View {
    /// Qeetrix styling for the navigation bar of this view's `NavigationStack` destination: the brand
    /// tint on the back button and toolbar buttons, and the chosen background.
    ///
    /// ```swift
    /// NavigationStack {
    ///     AccountList()
    ///         .navigationTitle("Accounts")
    ///         .toolbar {
    ///             ToolbarItem(placement: .primaryAction) {
    ///                 Button { add() } label: { Label { Text("Add account") } icon: { Image(qeetrix: .plus) } }
    ///             }
    ///         }
    ///         .qeetrixNavigationBar()
    /// }
    /// ```
    ///
    /// The bar stays the system's: back navigation, the swipe-back gesture, large and inline titles and
    /// toolbar layout are untouched. iOS draws the title in the system font and decides the bar's
    /// material and button chrome; Qeetrix sets only what the platform lets an app set — the tint and
    /// the background. For the titles in Qeet Sans, use `qeetrixNavigationBar(background:title:)`.
    public func qeetrixNavigationBar(background: QeetrixNavigationBarBackground = .automatic) -> some View {
        modifier(QeetrixNavigationBarModifier(background: background))
    }

    /// Qeetrix styling for this destination's navigation bar, with its titles in Qeet Sans when `title` is
    /// `.qeetrix`: a large title that collapses into the inline bar as the screen scrolls.
    ///
    /// ```swift
    /// NavigationStack {
    ///     List(accounts) { account in
    ///         Text(account.name)
    ///     }
    ///     .navigationTitle("Accounts")
    ///     .navigationBarTitleDisplayMode(.large)
    ///     .qeetrixNavigationBar(title: .qeetrix)
    /// }
    /// ```
    ///
    /// The bar, its large-title behaviour and its collapse stay the system's: choose large or inline with
    /// `navigationBarTitleDisplayMode(_:)`, as without Qeetrix. With `.qeetrix`, the large title is
    /// `heading.lg` and scales with Dynamic Type as the system's does; the inline title is `title.md`, at
    /// its size whatever the text size, as the system's, whose Large Content Viewer shows it larger. Once
    /// content scrolls under the bar, its edge is a 1 pt `color.border.default` rule; at the scroll edge
    /// there's none. With `.system` it is `qeetrixNavigationBar(background:)`.
    public func qeetrixNavigationBar(
        background: QeetrixNavigationBarBackground = .automatic, title: QeetrixNavigationBarTitle
    ) -> some View {
        modifier(QeetrixNavigationBarModifier(background: background, title: title))
    }
}

struct QeetrixNavigationBarModifier: ViewModifier {
    let background: QeetrixNavigationBarBackground
    var title: QeetrixNavigationBarTitle = .system
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.legibilityWeight) private var legibilityWeight

    func body(content: Content) -> some View {
        switch (title, background) {
        case (.system, .automatic):
            content.tint(QeetrixColor.textBrand)
        case (.system, .canvas):
            content
                .tint(QeetrixColor.textBrand)
                #if os(iOS)
                    .toolbarBackground(QeetrixColor.surfaceCanvas, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                #endif
        case (.qeetrix, _):
            // The titles' fonts are only settable on the bar's UIKit appearance, so the background goes
            // there too: one owner for the destination's appearance, rather than SwiftUI's toolbar
            // background and Qeetrix's fonts writing over each other.
            content
                .tint(QeetrixColor.textBrand)
                #if os(iOS)
                    .background {
                        QeetrixNavigationItemStyler(
                            style: QeetrixNavigationBarStyle(
                                background: background, dynamicTypeSize: dynamicTypeSize, legibilityWeight: legibilityWeight)
                        )
                        .frame(width: 0, height: 0)
                        .accessibilityHidden(true)
                    }
                #endif
        }
    }
}

/// The type and colours of a Qeetrix-titled bar, apart from UIKit so they can be checked anywhere.
struct QeetrixNavigationBarStyle: Equatable {
    let background: QeetrixNavigationBarBackground
    let dynamicTypeSize: DynamicTypeSize
    let legibilityWeight: LegibilityWeight?

    /// The large title: `heading.lg` (32/40, 600), on the `.largeTitle` Dynamic Type curve.
    static let largeTitleRole = QeetrixTextRole.headingLg
    /// The inline title: `title.md` (18/24, 600), the Dialog title's role.
    static let inlineTitleRole = QeetrixTextRole.titleMd
    /// The titles' colour.
    static let titleColor = QeetrixColor.textDefault
    /// The bar's edge once content is under it (the PageHeader's foot rule).
    static let ruleColor = QeetrixColor.borderDefault

    /// The weight drawn: one step heavier with Bold Text, as every role.
    func weight(_ role: QeetrixTextRole) -> QeetrixFontWeight {
        let tokens = role.tokens
        return legibilityWeight == .bold ? tokens.weight.bolder(in: tokens.family) : tokens.weight
    }
}

#if os(iOS)
    extension QeetrixNavigationBarStyle {
        /// The appearance once content scrolls under the bar, and the one at the scroll edge.
        @MainActor
        func appearances() -> (standard: UINavigationBarAppearance, scrollEdge: UINavigationBarAppearance) {
            let traits = UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory(dynamicTypeSize))
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: font(Self.inlineTitleRole, scaledLike: nil, traits: traits),
                .foregroundColor: Self.titleColor.qeetrixNavigationBarUIColor,
            ]
            let largeTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: font(Self.largeTitleRole, scaledLike: .largeTitle, traits: traits),
                .foregroundColor: Self.titleColor.qeetrixNavigationBarUIColor,
            ]
            let standard = UINavigationBarAppearance()
            let scrollEdge = UINavigationBarAppearance()
            switch background {
            case .automatic:
                standard.configureWithDefaultBackground()
                scrollEdge.configureWithTransparentBackground()
            case .canvas:
                standard.configureWithOpaqueBackground()
                scrollEdge.configureWithOpaqueBackground()
                standard.backgroundColor = QeetrixColor.surfaceCanvas.qeetrixNavigationBarUIColor
                scrollEdge.backgroundColor = QeetrixColor.surfaceCanvas.qeetrixNavigationBarUIColor
            }
            standard.shadowColor = Self.ruleColor.qeetrixNavigationBarUIColor
            scrollEdge.shadowColor = .clear
            for appearance in [standard, scrollEdge] {
                appearance.titleTextAttributes = titleAttributes
                appearance.largeTitleTextAttributes = largeTitleAttributes
            }
            return (standard, scrollEdge)
        }

        /// A role's font in Qeet Sans at its token size, scaled along `textStyle` for the text size in
        /// `traits` (none for the inline title, which the system keeps at one size).
        func font(_ role: QeetrixTextRole, scaledLike textStyle: UIFont.TextStyle?, traits: UITraitCollection) -> UIFont {
            let tokens = role.tokens
            let size =
                textStyle.map { UIFontMetrics(forTextStyle: $0).scaledValue(for: tokens.size, compatibleWith: traits) } ?? tokens.size
            let weight = weight(role)
            if let bundled = QeetrixFontRegistry.font(tokens.family, size: size, weight: weight, geometry: tokens.geometry) {
                return bundled as UIFont
            }
            return UIFont.systemFont(ofSize: size, weight: Self.systemWeight(weight))
        }

        /// The system font's nearest weight, for when Qeet Sans is unavailable.
        static func systemWeight(_ weight: QeetrixFontWeight) -> UIFont.Weight {
            switch weight.value {
            case ..<350: .light
            case ..<450: .regular
            case ..<550: .medium
            case ..<650: .semibold
            default: .bold
            }
        }
    }

    extension QeetrixColor {
        /// The colour as a UIKit colour that follows the trait collection's light or dark style.
        var qeetrixNavigationBarUIColor: UIColor {
            UIColor { traits in
                UIColor(self.color(for: traits.userInterfaceStyle == .dark ? .dark : .light))
            }
        }
    }

    /// Gives the destination it sits in — the view controller its navigation controller shows — the
    /// Qeetrix bar appearance. The appearance belongs to that destination's navigation item, so it comes
    /// and goes with it on push and pop and never reaches another screen.
    struct QeetrixNavigationItemStyler: UIViewControllerRepresentable {
        let style: QeetrixNavigationBarStyle

        func makeUIViewController(context: Context) -> Controller {
            Controller(style: style)
        }

        func updateUIViewController(_ controller: Controller, context: Context) {
            controller.style = style
        }

        final class Controller: UIViewController {
            var style: QeetrixNavigationBarStyle {
                didSet { if style != oldValue { apply() } }
            }

            init(style: QeetrixNavigationBarStyle) {
                self.style = style
                super.init(nibName: nil, bundle: nil)
            }

            @available(*, unavailable)
            required init?(coder: NSCoder) {
                fatalError("init(coder:) is not supported")
            }

            override func loadView() {
                let view = UIView()
                view.isUserInteractionEnabled = false
                view.isAccessibilityElement = false
                self.view = view
            }

            override func didMove(toParent parent: UIViewController?) {
                super.didMove(toParent: parent)
                apply()
            }

            override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                apply()
            }

            /// The destination: the nearest ancestor whose parent is a navigation controller.
            var destination: UIViewController? {
                var candidate = parent
                while let current = candidate {
                    if current.parent is UINavigationController { return current }
                    candidate = current.parent
                }
                return nil
            }

            func apply() {
                guard let item = destination?.navigationItem else { return }
                let appearances = style.appearances()
                item.standardAppearance = appearances.standard
                item.compactAppearance = appearances.standard
                item.scrollEdgeAppearance = appearances.scrollEdge
                item.compactScrollEdgeAppearance = appearances.scrollEdge
            }
        }
    }
#endif
