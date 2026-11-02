import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Chip")
struct ChipTests {
    private enum Status: Hashable { case open, closed }

    @Test("chip.css: control heights by size and density, label.md (label.sm at sm), 8 pt either side, 4 pt between parts")
    func metrics() {
        for density in QeetrixDensity.allCases {
            for size in QeetrixControlSize.allCases {
                #expect(QeetrixChipMetrics(size: size, density: density).height == density.controlHeight(size))
            }
        }
        #expect(QeetrixChipMetrics(size: .md, density: .default).type == QeetrixTypeSpec(.labelMd))
        #expect(QeetrixChipMetrics(size: .lg, density: .default).type == QeetrixTypeSpec(.labelMd))
        let small = QeetrixChipMetrics(size: .sm, density: .default).type
        #expect(small.tokens.size == QeetrixTextRole.labelSm.tokens.size && small.tokens.weight == .medium)
        #expect((QeetrixChipMetrics.padding, QeetrixChipMetrics.gap, QeetrixChipMetrics.labelPaddingBlock) == (8, 4, 2))
        #expect(QeetrixChipMetrics.iconSize == .sm)
    }

    @Test("Chosen shows the check before the label; an icon takes its place, chosen or not")
    func mark() {
        #expect(QeetrixChipMetrics.mark(icon: nil, isSelected: true) == .check)
        #expect(QeetrixChipMetrics.mark(icon: nil, isSelected: false) == nil)
        #expect(QeetrixChipMetrics.mark(icon: .bell, isSelected: true) == .bell)
        #expect(QeetrixChipMetrics.mark(icon: .bell, isSelected: false) == .bell)
    }

    @Test("Resting, hovered and pressed take the neutral tints inside a 1 pt border.subtle edge")
    func neutralStates() {
        func colors(_ state: QeetrixButtonState) -> QeetrixChipColors {
            QeetrixChipColors.colors(isSelected: false, isRemovable: false, state: state)
        }
        #expect(colors(.resting) == QeetrixChipColors(fill: .bgNeutralSubtle, edge: .borderSubtle, edgeWidth: 1, text: .textDefault))
        #expect(colors(.hovered).fill == .bgNeutralSubtleHover)
        #expect(colors(.pressed).fill == .bgNeutralSubtlePressed)
    }

    @Test("Chosen: bg.selected inside a 2 pt Ember edge, bg.selected-hover under the pointer and when pressed")
    func chosen() {
        let resting = QeetrixChipColors.colors(isSelected: true, isRemovable: false, state: .resting)
        #expect(resting == QeetrixChipColors(fill: .bgSelected, edge: .borderBrand, edgeWidth: 2, text: .textDefault))
        for state in [QeetrixButtonState.hovered, .pressed] {
            #expect(QeetrixChipColors.colors(isSelected: true, isRemovable: false, state: state).fill == .bgSelectedHover)
        }
    }

    @Test("Disabled: bg.disabled, the disabled edge and text; a removable chip's label stays text.subtlest")
    func disabled() {
        let chip = QeetrixChipColors.colors(isSelected: true, isRemovable: false, state: .disabled)
        #expect(chip == QeetrixChipColors(fill: .bgDisabled, edge: .borderDisabled, edgeWidth: 1, text: .textDisabled))
        #expect(QeetrixChipColors.colors(isSelected: false, isRemovable: true, state: .disabled).text == .textSubtlest)
    }

    @Test("A removable chip has no hover or press of its own")
    func removableStates() {
        for state in [QeetrixButtonState.resting, .hovered, .pressed] {
            #expect(QeetrixChipColors.colors(isSelected: false, isRemovable: true, state: state).fill == .bgNeutralSubtle)
        }
    }

    @Test("The remove button is named \"Remove {label}\"")
    func removeName() {
        #expect(QeetrixChipStrings.remove("Status: Active") == "Remove Status: Active")
        // A Text label takes the stand-in's place in the localised sentence; this renders it.
        #expect(ImageRenderer(content: QeetrixChipStrings.remove(Text("Unread"))).cgImage != nil)
    }

    @Test("The drawn chip: the neutral tint and edge, or the selected tint inside the Ember edge")
    func drawn() throws {
        func render(_ selected: Bool) throws -> Rendered {
            try #require(
                Rendered(QeetrixChip("Unread", isSelected: .constant(selected)).fixedSize().environment(\.colorScheme, .light)))
        }
        let light = QeetrixTheme.light
        let plain = try render(false)
        #expect(plain.height == 32)
        #expect(close(light.resolve(.bgNeutralSubtle).bytes, plain.pixel(4, plain.height / 2)))
        let chosen = try render(true)
        #expect(close(light.resolve(.borderBrand).bytes, chosen.pixel(0, chosen.height / 2)))
        #expect(close(light.resolve(.borderBrand).bytes, chosen.pixel(1, chosen.height / 2)))
        #expect(close(light.resolve(.bgSelected).bytes, chosen.pixel(3, chosen.height / 2)))
        #expect(chosen.width > plain.width, "the check is added before the label")
    }

    @Test("Sizes are the controls' heights; a long label wraps instead of being cut")
    func heights() throws {
        for (size, height) in [(QeetrixControlSize.sm, 28), (.md, 32), (.lg, 40)] {
            let image = try #require(Rendered(QeetrixChip("Unread", isSelected: .constant(false), size: size).fixedSize()))
            #expect(image.height == height, "\(size)")
        }
        let long = QeetrixChip("Status: Active, Invited and Suspended accounts", isSelected: .constant(false))
            .frame(width: 120)
        let wrapped = try #require(Rendered(long.fixedSize(horizontal: false, vertical: true)))
        #expect(wrapped.height > 32)
    }

    @Test("A multiple-choice group turns each value on or off")
    func toggled() {
        let values: Set<Status> = [.open]
        #expect(QeetrixChipGroup<Status>.toggled(values, .closed, isOn: true) == [.open, .closed])
        #expect(QeetrixChipGroup<Status>.toggled(values, .open, isOn: false) == [])
        #expect(QeetrixChipGroup<Status>.toggled(values, .open, isOn: true) == [.open])
    }

    @Test("The flow: 44 pt slots 8 pt apart, wrapping, rows at least 8 pt apart and never closer than 44 pt targets")
    func flow() {
        let chip = CGSize(width: 60, height: 32)
        // Three chips in 200 pt: 60 + 8 + 60 = 128, a third would end at 196, a fourth wraps.
        let rows = QeetrixChipFlowLayout.rows(sizes: Array(repeating: chip, count: 4), width: 200)
        #expect(rows.map(\.indices) == [[0, 1, 2], [3]])
        #expect(rows[0].slots.map(\.minX) == [0, 68, 136])
        #expect(rows[0].height == 44 && rows[0].tallest == 32)
        // 32 pt chips in 44 pt rows already leave 12 pt between them: the rows touch.
        #expect(rows[1].y == 44)
        // A short chip still gets a 44 pt slot.
        let short = QeetrixChipFlowLayout.rows(sizes: [CGSize(width: 30, height: 28), chip], width: 400)
        #expect(short[0].slots.map(\.width) == [44, 60])
        #expect(short[0].slots[1].minX == 52)
        // 40 pt chips leave 4 pt: the rows are 4 pt apart so the chips are 8 pt apart.
        let large = QeetrixChipFlowLayout.rows(sizes: Array(repeating: CGSize(width: 150, height: 40), count: 2), width: 200)
        #expect(large.map(\.y) == [0, 48])
        // A chip taller than 44 pt sets its row, and the next row is a full 8 pt below it.
        let tall = QeetrixChipFlowLayout.rows(sizes: [CGSize(width: 150, height: 60), CGSize(width: 150, height: 60)], width: 200)
        #expect(tall.map(\.y) == [0, 68])
    }

    @Test("Overflow names are the web's layout words")
    func overflow() {
        #expect(QeetrixChipGroupOverflow.allCases.map(\.rawValue) == ["wrap", "scroll"])
    }

    @Test("Chips and groups render: selectable, removable, disabled, single and multiple, wrapping and scrolling")
    func renders() {
        let options = [QeetrixOption("Open", value: Status.open), QeetrixOption("Closed", value: Status.closed, isDisabled: true)]
        for scheme in [ColorScheme.light, .dark] {
            let view = VStack {
                QeetrixChip("Unread", isSelected: .constant(true), icon: .bell, size: .sm)
                QeetrixChip("Status: Active", size: .lg) {}
                QeetrixChip("Status: Active") {}.disabled(true)
                Toggle("Starred", isOn: .constant(false)).toggleStyle(.qeetrixChip(icon: .pin))
                QeetrixChipGroup("Status", selection: .constant(Status.open), options: options)
                QeetrixChipGroup("Status", selection: .constant(Set([Status.open])), options: options, overflow: .scroll)
                QeetrixChipFlowLayout {
                    QeetrixChip("One") {}
                    QeetrixChip("Two") {}
                }
            }
            .frame(width: 360)
            .environment(\.colorScheme, scheme)
            #expect(ImageRenderer(content: view).cgImage != nil)
        }
    }
}
