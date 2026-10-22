import SwiftUI
import Testing

@testable import Qeetrix

/// Phase 6, findings A11Y-5 and A11Y-6: at the accessibility sizes icons spilled out of fixed squares —
/// icon buttons over their neighbours, the password eye over the field's edge — and the select cut its
/// value to one line. Each test renders at the largest size against the same view at the default one.
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

    @Test("An icon square is the web's size at the default text size, and grows with its icon beyond it")
    func iconSquare() throws {
        let square = QeetrixIcon(.bell, size: QeetrixIconSize(16)).qeetrixIconSquare(36, icon: 16)
        let regular = try rendered(square)
        #expect(regular.width == 36 && regular.height == 36)
        let icon = try scaledBell()
        let large = try rendered(square, Self.largest)
        #expect(large.width >= icon.width + 20 && large.height >= icon.height + 20, "The 10 pt inset is kept")
    }

    @Test("An icon button holds its icon at every text size, and keeps its size while busy")
    func iconButton() throws {
        let idle = QeetrixIconButton(.bell, label: "Notifications", variant: .outline) {}
        let busy = QeetrixIconButton(.bell, label: "Notifications", variant: .outline, isLoading: true) {}
        let side = Int(QeetrixButtonMetrics(size: .default, density: .default).height)
        #expect(try rendered(idle).width == side)
        let icon = try scaledBell()
        let large = try rendered(idle, Self.largest)
        #expect(large.width >= icon.width + (side - 16), "The square grows with the icon instead of letting it spill out")
        #expect(try rendered(busy, Self.largest).width == large.width, "The busy indicator scales as the icon does")
    }

    @Test("A checkbox's mark stays inside its box: both keep their size at the largest text size")
    func checkboxMark() throws {
        for mark in [QeetrixCheckboxMark.checked, .mixed] {
            let box = QeetrixCheckboxBox(mark: mark, isHovered: false, tone: nil).environment(\.colorScheme, .light)
            let regular = try rendered(box)
            let large = try rendered(box, Self.largest)
            #expect(regular.width == large.width && regular.height == large.height)
            let same = (0..<regular.height).allSatisfy { y in
                (0..<regular.width).allSatisfy { x in regular.pixel(x, y) == large.pixel(x, y) }
            }
            #expect(same, "The \(mark) mark is drawn the same at the default and the largest size")
        }
    }

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
}

extension QeetrixCheckboxMark: CustomStringConvertible {
    public var description: String { "\(self == .checked ? "checked" : self == .mixed ? "mixed" : "unchecked")" }
}
