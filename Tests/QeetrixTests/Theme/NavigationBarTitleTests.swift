import SwiftUI
import Testing

@testable import Qeetrix

#if canImport(UIKit)
    import UIKit
#endif

@MainActor
@Suite("Large and collapsing title")
struct NavigationBarTitleTests {
    private let style = QeetrixNavigationBarStyle(background: .automatic, dynamicTypeSize: .large, legibilityWeight: .regular)

    @Test("Two typefaces: the system's, as before, or Qeet Sans")
    func titles() {
        #expect(QeetrixNavigationBarTitle.allCases == [.system, .qeetrix])
        #expect(QeetrixNavigationBarTitle.allCases.map(\.rawValue) == ["system", "qeetrix"])
        #expect(QeetrixNavigationBarModifier(background: .automatic).title == .system, "qeetrixNavigationBar(background:) is unchanged")
    }

    @Test("heading.lg large, title.md inline, in text.default; the bar's edge in border.default")
    func roles() {
        #expect(QeetrixNavigationBarStyle.largeTitleRole == .headingLg)
        #expect(QeetrixNavigationBarStyle.largeTitleRole.textStyle == .largeTitle)
        #expect(QeetrixNavigationBarStyle.inlineTitleRole == .titleMd)
        #expect(QeetrixNavigationBarStyle.titleColor == .textDefault)
        #expect(QeetrixNavigationBarStyle.ruleColor == .borderDefault)
        #expect(style.weight(.headingLg) == .semibold)
        let bold = QeetrixNavigationBarStyle(background: .automatic, dynamicTypeSize: .large, legibilityWeight: .bold)
        #expect(bold.weight(.headingLg) > .semibold, "Bold Text: one step heavier")
    }

    @Test("Both forms attach to a destination and render")
    func attaches() {
        for background in QeetrixNavigationBarBackground.allCases {
            for title in QeetrixNavigationBarTitle.allCases {
                let view = Text("Accounts").qeetrixNavigationBar(background: background, title: title)
                #expect(ImageRenderer(content: view).cgImage != nil)
            }
        }
        #expect(ImageRenderer(content: Text("Accounts").qeetrixNavigationBar()).cgImage != nil)
    }

    #if os(iOS)
        @Test("The appearance: Qeet Sans titles at their sizes, the rule once content is under the bar")
        func appearance() throws {
            let (standard, scrollEdge) = style.appearances()
            let large = try #require(standard.largeTitleTextAttributes[.font] as? UIFont)
            let inline = try #require(standard.titleTextAttributes[.font] as? UIFont)
            #expect(large.familyName == QeetrixFontFamily.sans.face.familyName)
            #expect(large.pointSize == 32)
            #expect(inline.familyName == QeetrixFontFamily.sans.face.familyName)
            #expect(inline.pointSize == 18)
            #expect(scrollEdge.largeTitleTextAttributes[.font] as? UIFont == large)
            let light = UITraitCollection(userInterfaceStyle: .light)
            let rule = try #require(standard.shadowColor).resolvedColor(with: light)
            #expect(rule == UIColor(QeetrixColor.borderDefault.color(for: .light)).resolvedColor(with: light))
            // UIKit reads a clear shadow back as nil; either way nothing is drawn.
            #expect((scrollEdge.shadowColor?.cgColor.alpha ?? 0) == 0, "No rule at the scroll edge")
        }

        @Test("The large title grows with Dynamic Type; the inline title keeps its size, as the system's")
        func dynamicType() throws {
            let larger = QeetrixNavigationBarStyle(background: .automatic, dynamicTypeSize: .accessibility3, legibilityWeight: nil)
            let (standard, _) = larger.appearances()
            let large = try #require(standard.largeTitleTextAttributes[.font] as? UIFont)
            let inline = try #require(standard.titleTextAttributes[.font] as? UIFont)
            #expect(large.pointSize > 32)
            #expect(inline.pointSize == 18)
        }

        @Test("Canvas: an opaque bar in surface.canvas, at the scroll edge too")
        func canvas() throws {
            let (standard, scrollEdge) = QeetrixNavigationBarStyle(background: .canvas, dynamicTypeSize: .large, legibilityWeight: nil)
                .appearances()
            let dark = UITraitCollection(userInterfaceStyle: .dark)
            let canvas = UIColor(QeetrixColor.surfaceCanvas.color(for: .dark)).resolvedColor(with: dark)
            #expect(try #require(standard.backgroundColor).resolvedColor(with: dark) == canvas)
            #expect(try #require(scrollEdge.backgroundColor).resolvedColor(with: dark) == canvas)
        }

        @Test("In a NavigationStack, the destination's navigation item carries the Qeetrix appearance")
        func installed() async throws {
            let root = NavigationStack {
                Text("Accounts")
                    .navigationTitle("Accounts")
                    .qeetrixNavigationBar(title: .qeetrix)
            }
            let host = UIHostingController(rootView: root)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
            window.rootViewController = host
            window.isHidden = false
            defer {
                window.isHidden = true
                window.rootViewController = nil
            }
            host.view.layoutIfNeeded()
            try await Task.sleep(for: .milliseconds(200))
            func navigationController(in controller: UIViewController) -> UINavigationController? {
                if let navigation = controller as? UINavigationController { return navigation }
                return controller.children.lazy.compactMap(navigationController(in:)).first
            }
            let navigation = try #require(navigationController(in: host))
            let item = try #require(navigation.viewControllers.first?.navigationItem)
            let large = try #require(item.standardAppearance?.largeTitleTextAttributes[.font] as? UIFont)
            #expect(large.familyName == QeetrixFontFamily.sans.face.familyName)
        }
    #endif
}
