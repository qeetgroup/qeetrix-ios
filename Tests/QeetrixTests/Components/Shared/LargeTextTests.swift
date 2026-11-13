import SwiftUI
import Testing

@testable import Qeetrix

/// Phase 6, findings A11Y-5 and A11Y-6: at the accessibility sizes icons spilled out of fixed squares —
/// icon buttons over their neighbours, the password eye over the field's edge — and the select cut its
/// value to one line. Kept through the move to `@qeetrix/react`, against the re-specified components. Each test renders at the largest size against the same view at the default one.
@MainActor
@Suite("The largest text sizes")
struct LargeTextTests {
    static let largest = DynamicTypeSize.accessibility5

    func rendered(_ view: some View, _ size: DynamicTypeSize = .large) throws -> Rendered {
        try #require(Rendered(view.environment(\.dynamicTypeSize, size)))
    }

    /// The bell at 16 pt, as rendered at the largest size. On iOS it scales with Dynamic Type; the Mac
    /// host has no Dynamic Type, so there these tests check only the default size and the select.
    func scaledBell() throws -> Rendered {
        let icon = try rendered(QeetrixIcon(.bell, size: QeetrixIconSize(16)), Self.largest)
        #if os(iOS)
            #expect(icon.width > 16, "The icon scales at the largest size, so the checks below mean something")
        #endif
        return icon
    }

    @Test("An icon button holds its icon at every text size, and keeps its size while busy")
    func iconButton() throws {
        let idle = QeetrixIconButton(.bell, label: "Notifications", variant: .soft) {}
        let busy = QeetrixIconButton(.bell, label: "Notifications", variant: .soft, isLoading: true) {}
        let side = Int(QeetrixButtonMetrics(size: .md, density: .default).height)
        #expect(try rendered(idle).width == side)
        let icon = try scaledBell()
        let large = try rendered(idle, Self.largest)
        #expect(large.width >= icon.width + (side - 16), "The square grows with the icon instead of letting it spill out")
        #expect(try rendered(busy, Self.largest).width == large.width, "The busy indicator scales as the icon does")
    }

    @Test("A checkbox's mark stays inside its box: both keep their size at the largest text size")
    func checkboxMark() throws {
        for mark in [QeetrixCheckboxMark.checked, .mixed] {
            let box = QeetrixCheckboxBox(mark: mark, isHovered: false, isEnabled: true, isInvalid: false)
                .environment(\.colorScheme, .light)
            let regular = try rendered(box)
            let large = try rendered(box, Self.largest)
            #expect(regular.width == large.width && regular.height == large.height)
            var same = true
            for y in 0..<regular.height {
                for x in 0..<regular.width where regular.pixel(x, y) != large.pixel(x, y) {
                    same = false
                }
            }
            #expect(same, "The \(mark) mark is drawn the same at the default and the largest size")
        }
    }

    // iOS only: on the Mac host SwiftUI draws a `Menu` as a native pop-up button, which keeps its label to one line
    // whatever the label asks, so the measurement means nothing there. It runs in the iOS Simulator tests.
    #if os(iOS)
        @Test("At the accessibility sizes the select's value wraps instead of being cut to one line")
        func selectWraps() throws {
            let options: [QeetrixOption<String?>] = [QeetrixOption("India", value: "IN")]
            func select(_ placeholder: String) -> some View {
                QeetrixSelect("Country", selection: .constant(nil), options: options, placeholder: Text(verbatim: placeholder))
                    .frame(width: 240)
            }
            let short = try rendered(select("Choose"), Self.largest)
            let long = try rendered(select("Choose a country or a region"), Self.largest)
            #expect(long.height > short.height, "The long value takes more than one line")
            #expect(
                try rendered(select("Choose a country or a region")).height == rendered(select("Choose")).height,
                "At the default size it stays one line, as the web's line-clamp-1")
        }
    #endif
}

extension QeetrixCheckboxMark: CustomStringConvertible {
    public var description: String { "\(self == .checked ? "checked" : self == .mixed ? "mixed" : "unchecked")" }
}
