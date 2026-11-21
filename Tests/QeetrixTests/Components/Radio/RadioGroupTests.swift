import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Radio group")
struct RadioGroupTests {
    enum Plan: Hashable { case starter, team }

    @Test("Options identify by their value, so a selection no option has selects nothing")
    func identity() {
        let options: [QeetrixOption<Plan?>] = [QeetrixOption("Starter", value: .starter), QeetrixOption("Team", value: .team)]
        #expect(options.map(\.id) == [.starter, .team])
        let selection: Plan? = nil
        #expect(!options.contains { $0.value == selection })
    }

    @Test("radio.css: a strong edge at rest, a 5 pt Ember ring when selected, disabled greys")
    func disc() {
        #expect(QeetrixRadioDisc.side == 16 && QeetrixRadioDisc.selectedRing == 5)
        #expect(QeetrixRadioDisc(isSelected: false).border == .borderStrong)
        #expect(QeetrixRadioDisc(isSelected: false, isHovered: true).border == .borderStrongHover)
        #expect(QeetrixRadioDisc(isSelected: true).border == .bgBrandBold)
        #expect(QeetrixRadioDisc(isSelected: true, isHovered: true).border == .bgBrandBoldHover)
        #expect(QeetrixRadioDisc(isSelected: true, isEnabled: false).border == .iconDisabled)
        #expect(QeetrixRadioDisc(isSelected: false, isEnabled: false).border == .borderDisabled)
    }

    @Test("A selected radio is an Ember ring round an input-coloured centre")
    func drawn() throws {
        let image = try #require(Rendered(QeetrixRadioDisc(isSelected: true).environment(\.colorScheme, .light)))
        #expect(image.width == 16)
        #expect(close(QeetrixTheme.light.resolve(.bgBrandBold).bytes, image.pixel(2, 8)))
        #expect(close(QeetrixTheme.light.resolve(.bgInput).bytes, image.pixel(8, 8)))
    }

    @Test("With an error the chosen radio's ring is the danger colour")
    func invalidRing() throws {
        let image = try #require(
            Rendered(QeetrixRadioDisc(isSelected: true).environment(\.qeetrixGroupIsInvalid, true).environment(\.colorScheme, .light)))
        #expect(close(QeetrixTheme.light.resolve(.borderDanger).bytes, image.pixel(2, 8)))
        #expect(close(QeetrixTheme.light.resolve(.bgInput).bytes, image.pixel(8, 8)))
        let hovered = try #require(
            Rendered(
                QeetrixRadioDisc(isSelected: true, isHovered: true).environment(\.qeetrixGroupIsInvalid, true).environment(
                    \.colorScheme, .light)))
        #expect(close(QeetrixTheme.light.resolve(.borderDanger).bytes, hovered.pixel(2, 8)))
    }

    @Test("Renders vertical and horizontal, with a selection, a disabled option and an error")
    func renders() {
        let options = [QeetrixOption("Starter", value: Plan.starter), QeetrixOption("Team", value: .team, isDisabled: true)]
        for orientation in QeetrixChoiceOrientation.allCases {
            let group = QeetrixRadioGroup(
                "Plan", selection: .constant(Plan.starter), options: options, error: "Choose a plan", orientation: orientation)
            #expect(ImageRenderer(content: group.frame(width: 300)).cgImage != nil)
        }
    }

    @Test("Variants are @qeetrix/react's ChoiceVariant; options carry an icon only when given one")
    func variants() {
        #expect(QeetrixChoiceVariant.allCases.map(\.rawValue) == ["default", "tile"])
        #expect(QeetrixOption("Everyone", value: 1).icon == nil)
        #expect(QeetrixOption("Everyone", value: 1, description: Text("Anyone with your number"), icon: .users).icon == .users)
    }

    @Test("field.css tiles: surface with a subtle edge; chosen, bg.selected with a 2 pt brand edge; lit, the neutral tint; disabled greys")
    func tileColours() {
        typealias Style = QeetrixRadioTileStyle
        #expect(Style.fill(isSelected: false, isEnabled: true, isLit: false) == .surfaceDefault)
        #expect(Style.fill(isSelected: false, isEnabled: true, isLit: true) == .bgNeutralSubtle)
        #expect(Style.fill(isSelected: true, isEnabled: true, isLit: false) == .bgSelected)
        #expect(Style.fill(isSelected: true, isEnabled: true, isLit: true) == .bgSelected, "hover never covers the chosen fill")
        #expect(Style.fill(isSelected: true, isEnabled: false, isLit: false) == .bgDisabled)
        func edge(_ isSelected: Bool, _ isEnabled: Bool) -> String {
            let edge = Style.edge(isSelected: isSelected, isEnabled: isEnabled)
            return "\(edge.color.rawValue) \(edge.width)"
        }
        #expect(edge(false, true) == "color.border.subtle 1.0")
        #expect(edge(true, true) == "color.border.brand 2.0")
        #expect(edge(true, false) == "color.border.disabled 1.0")
        #expect(QeetrixRadioTileMetrics.iconBox == 36)
        #expect(QeetrixRadioTileMetrics.titleType.tokens.weight == .semibold)
        #expect(QeetrixRadioTileMetrics.titleType.tokens.size == QeetrixTextRole.bodyMd.tokens.size)
    }

    private func tile(_ isSelected: Bool, icon: QeetrixIconName? = nil, description: Text? = nil) -> some View {
        let option =
            icon.map { QeetrixOption("Everyone", value: 1, description: description, icon: $0) }
            ?? QeetrixOption("Everyone", value: 1, description: description)
        return QeetrixRadioTile(option: option, isSelected: isSelected) {}
            .frame(width: 300)
            .environment(\.colorScheme, .light)
    }

    @Test("A tile: 12 pt in, the edge inside it, the radio at the top end on the title's line, at least 44 pt tall")
    func tileDrawn() throws {
        let light = QeetrixTheme.light
        let chosen = try #require(Rendered(tile(true)))
        // One line of body.md (20 pt) and 12 pt above and below; text frames round to the screen's pixels.
        #expect(chosen.width == 300 && abs(chosen.height - 44) <= 1, "\(chosen.height)")
        #expect(
            close(light.resolve(.borderBrand).bytes, chosen.pixel(0, 22)) && close(light.resolve(.borderBrand).bytes, chosen.pixel(1, 22)))
        #expect(close(light.resolve(.bgSelected).bytes, chosen.pixel(3, 22)))
        // The radio: 16 pt, 12 pt in from the end, centred on the 20 pt line 12 pt down; its 5 pt ring.
        #expect(close(light.resolve(.bgBrandBold).bytes, chosen.pixel(300 - 12 - 8 - 6, 22)))
        #expect(close(light.resolve(.bgInput).bytes, chosen.pixel(300 - 12 - 8, 22)))
        let resting = try #require(Rendered(tile(false)))
        #expect(close(light.resolve(.borderSubtle).bytes, resting.pixel(0, 22)))
        #expect(close(light.resolve(.surfaceDefault).bytes, resting.pixel(1, 22)))
    }

    @Test("A tile with an icon: the 36 pt box at its start, white once chosen, and the tile at least 60 pt tall")
    func tileIcon() throws {
        let light = QeetrixTheme.light
        let resting = try #require(Rendered(tile(false, icon: .users)))
        #expect(resting.height == 60, "calc(36px + 2 × space.inset.md)")
        #expect(close(light.resolve(.bgNeutralSubtle).bytes, resting.pixel(14, 14)), "the box, 12 pt in")
        let chosen = try #require(Rendered(tile(true, icon: .users)))
        #expect(close(light.resolve(.surfaceDefault).bytes, chosen.pixel(14, 14)))
        // A description makes the tile taller only past the box's height: here its line and the title's
        // (20 + 16 pt) are the box's 36 pt, give or take each text frame's rounding to the screen's pixels.
        let described = try #require(Rendered(tile(false, icon: .users, description: Text("Anyone with your number"))))
        #expect(abs(described.height - 60) <= 2, "\(described.height)")
    }

    @Test("The tile grid: equal tracks 8 pt apart, rows 8 pt apart, every tile in a row as tall as the tallest")
    func tileGrid() throws {
        func cell(_ color: Color, _ height: CGFloat) -> some View {
            Rectangle().fill(color).frame(minHeight: height, maxHeight: .infinity)
        }
        let grid = QeetrixTileGridLayout(columns: 2, spacing: 8) {
            cell(.red, 20)
            cell(.blue, 40)
            cell(.green, 10)
        }
        .frame(width: 208)
        let image = try #require(Rendered(grid))
        #expect(image.width == 208 && image.height == 40 + 8 + 10)
        #expect(image.pixel(50, 35).r > 200, "the short tile stretches to its row")
        #expect(image.pixel(150, 35).b > 200)
        #expect(image.pixel(104, 20).a == 0, "the 8 pt gap between tracks")
        #expect(image.pixel(50, 44).a == 0, "the 8 pt gap between rows")
        #expect(image.pixel(50, 53).g > 100 && image.pixel(150, 53).a == 0)
        // Right to left, the first track is on the right.
        let mirrored = try #require(Rendered(grid.environment(\.layoutDirection, .rightToLeft)))
        #expect(mirrored.pixel(150, 35).r > 200 && mirrored.pixel(50, 35).b > 200)
    }

    @Test("Tiles take up to `columns`: fewer where a tile would be under 8rem, or 12rem with an icon or a description")
    func tileColumns() throws {
        // The minimums, from the pinned stylesheet itself (1rem = 16 pt).
        let css = String(decoding: try Repository.data("Upstream/qeetrix-react/css/field.css"), as: UTF8.self)
        #expect(css.contains("--qx-choice-tile-min: 8rem") && css.contains("--qx-choice-tile-min: 12rem"))
        #expect(QeetrixRadioTileMetrics.minimumWidth(isDetailed: false) == CGFloat(8 * 16))
        #expect(QeetrixRadioTileMetrics.minimumWidth(isDetailed: true) == CGFloat(12 * 16))
        let plain = QeetrixTileGridLayout(columns: 2, spacing: 8, minimumWidth: 128)
        #expect(plain.columnCount(width: 358) == 2, "a 390 pt phone's content: two 175 pt tiles")
        #expect(plain.columnCount(width: 250) == 1, "two shares would be 121 pt")
        let detailed = QeetrixTileGridLayout(columns: 2, spacing: 8, minimumWidth: 192)
        #expect(detailed.columnCount(width: 358) == 1)
        #expect(detailed.columnCount(width: 400) == 2)
        let four = QeetrixTileGridLayout(columns: 4, spacing: 8, minimumWidth: 128)
        #expect(four.columnCount(width: 358) == 2, "as many 128 pt tracks as fit")
        #expect(four.columnCount(width: 600) == 4)
        #expect(four.columnCount(width: 100) == 1, "never none")
        // Drawn: two plain tiles side by side on a phone, stacked where they'd be too narrow.
        func height(_ width: CGFloat) throws -> Int {
            let group = QeetrixRadioGroup(
                "Language", selection: .constant(1), options: [QeetrixOption("English", value: 1), QeetrixOption("हिन्दी", value: 2)],
                variant: .tile, columns: 2)
            return try #require(Rendered(group.frame(width: width))).height
        }
        let wide = try height(358)
        let narrow = try height(250)
        #expect(narrow >= wide + 44 + 8 - 1, "\(wide) → \(narrow): a second row of tiles, 8 pt below the first")
    }

    #if os(macOS)
        @Test("Each tile is a button, selected or not, named by its title with its description as the hint")
        func tileAccessibility() {
            let group = QeetrixRadioGroup(
                "Who can see your photo", selection: .constant(2),
                options: [
                    QeetrixOption("Everyone", value: 1, description: Text("Anyone with your number"), icon: .users),
                    QeetrixOption("My contacts", value: 2, icon: .contactRound),
                ],
                variant: .tile, columns: 2)
            let elements = ListsAccessibilityTree.elements(of: group)
            let buttons = elements.filter { $0.role == "AXButton" }
            #expect(buttons.map(\.text) == ["Everyone", "My contacts"], "\(elements)")
            #expect(buttons.map(\.isSelected) == [false, true])
        }
    #endif

    @Test("Tile groups render in one to four columns, with icons, descriptions, a disabled option and an error, in both schemes")
    func tileRenders() {
        let options = [
            QeetrixOption("Everyone", value: 1, description: Text("Anyone with your number"), icon: .users),
            QeetrixOption("My contacts", value: 2, icon: .contactRound),
            QeetrixOption("Nobody", value: 3, isDisabled: true),
        ]
        for columns in 1...4 {
            for scheme in [ColorScheme.light, .dark] {
                let group = QeetrixRadioGroup(
                    "Who can see your photo", selection: .constant(2), options: options, error: columns == 4 ? "Choose one" : nil,
                    variant: .tile, columns: columns)
                #expect(ImageRenderer(content: group.frame(width: 360).environment(\.colorScheme, scheme)).cgImage != nil)
            }
        }
        let rows = QeetrixRadioGroup("Who can see your photo", selection: .constant(2), options: options, variant: .default)
        #expect(ImageRenderer(content: rows.frame(width: 360)).cgImage != nil, "the row form draws the icons too")
    }
}
