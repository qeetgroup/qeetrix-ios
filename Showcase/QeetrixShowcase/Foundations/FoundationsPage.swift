import Qeetrix
import SwiftUI

/// The foundations on one page: theme switching, the colour groups in both schemes, the 18 type roles
/// with Dynamic Type, space, radii, borders, shadows, densities, motion and icons. Built only from the
/// public Qeetrix API, and laid out to stay readable at every text size: rows fall back to stacks when
/// they do not fit.
struct FoundationsPage: View {
    @Binding var mode: QeetrixThemeMode
    @State private var typeSize: DynamicTypeSize = .large
    @State private var colourGroup = ColourGroup.surface
    @State private var isMoved = false
    @ScaledMetric(relativeTo: .body) private var iconCell: CGFloat = 32
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum ColourGroup: String, CaseIterable, Identifiable {
        case surface, bg, text, icon, border
        var id: Self { self }
        var colours: [QeetrixColor] {
            QeetrixColor.allCases.filter { $0.rawValue.hasPrefix("color.\(rawValue).") }
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: QeetrixSpace.layoutMd) {
                    header
                    section("Theme") { themePicker }
                    section("Colours") { colours }
                    section("Typography") { typography }
                    section("Space") { space }
                    section("Radii and borders") { radiiAndBorders }
                    section("Shadows") { shadows }
                    section("Densities") { densities }
                    section("Motion") { motion }
                    section("Icons") { icons }
                }
                .padding(QeetrixSpace.insetLg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(QeetrixColor.surfaceCanvas)
            .navigationTitle("Foundations")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // `-section icons` at launch opens at that section, for screenshots of each foundation.
                if let section = UserDefaults.standard.string(forKey: "section") {
                    proxy.scrollTo(section, anchor: .top)
                }
            }
        }
    }

    private var header: some View {
        let provenance = try? QeetrixProvenance.bundled()
        return VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
            QeetrixHeading("Qeetrix", level: 1, size: .displaySm)
            QeetrixText(
                "Tokens from @qeetrix/tokens \(provenance?.tokens.version ?? "?"), components after @qeetrix/react \(provenance?.components.version ?? "?")",
                tone: .subtle)
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
            QeetrixHeading(title, level: 2, size: .headingSm)
            content()
        }
        .id(title.lowercased().components(separatedBy: " ").first ?? title)
    }

    /// Side by side when there is room, stacked when there is not (large text, narrow screens).
    private func adaptiveRow<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: QeetrixSpace.gapMd) { content() }
            VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) { content() }
        }
    }

    private func caption(_ text: String) -> some View {
        QeetrixText(text, size: .sm, tone: .subtle)
    }

    // MARK: Theme

    private var themePicker: some View {
        ViewThatFits(in: .horizontal) {
            Picker("Theme", selection: $mode) { themeOptions }.pickerStyle(.segmented)
            Picker("Theme", selection: $mode) { themeOptions }.pickerStyle(.menu)
        }
    }

    private var themeOptions: some View {
        ForEach(QeetrixThemeMode.allCases) { Text($0.rawValue.capitalized).tag($0) }
    }

    // MARK: Colours

    private var colours: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
            Picker("Colour group", selection: $colourGroup) {
                ForEach(ColourGroup.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            adaptiveRow {
                palette("Light").qeetrixTheme(.light)
                palette("Dark").qeetrixTheme(.dark)
            }
        }
    }

    private func palette(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
            QeetrixText(title, weight: .medium, tone: .default)
            ForEach(colourGroup.colours, id: \.self) { color in
                HStack(spacing: QeetrixSpace.gapSm) {
                    RoundedRectangle(cornerRadius: QeetrixRadius.sm)
                        .fill(color)
                        .frame(width: 24, height: 24)
                        .overlay(RoundedRectangle(cornerRadius: QeetrixRadius.sm).strokeBorder(QeetrixColor.borderDefault))
                        .accessibilityHidden(true)
                    QeetrixText(color.rawValue.replacingOccurrences(of: "color.", with: ""), size: .sm, tone: .subtle)
                }
            }
        }
        .padding(QeetrixSpace.insetMd)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(QeetrixColor.surfaceRaised, in: RoundedRectangle(cornerRadius: QeetrixRadius.surface))
        .overlay(RoundedRectangle(cornerRadius: QeetrixRadius.surface).strokeBorder(QeetrixColor.borderDefault))
    }

    // MARK: Typography

    private var typography: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
            Picker("Preview text size", selection: $typeSize) {
                ForEach([DynamicTypeSize.small, .large, .xxxLarge, .accessibility3], id: \.self) { size in
                    Text(String(describing: size)).tag(size)
                }
            }
            .pickerStyle(.menu)
            VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
                ForEach(QeetrixTextRole.allCases, id: \.self) { role in
                    Text(role == .labelCaps ? role.rawValue.uppercased() : "\(role.rawValue) — the quick brown fox")
                        .qeetrixTextStyle(role)
                        .foregroundStyle(QeetrixColor.textDefault)
                }
            }
            .dynamicTypeSize(typeSize)
        }
    }

    // MARK: Space, radii, borders

    private static let space: [(String, CGFloat)] = [
        ("inset.xs", QeetrixSpace.insetXs), ("inset.sm", QeetrixSpace.insetSm), ("inset.md", QeetrixSpace.insetMd),
        ("inset.lg", QeetrixSpace.insetLg), ("inset.xl", QeetrixSpace.insetXl), ("gap.xs", QeetrixSpace.gapXs),
        ("gap.sm", QeetrixSpace.gapSm), ("gap.md", QeetrixSpace.gapMd), ("gap.lg", QeetrixSpace.gapLg), ("gap.xl", QeetrixSpace.gapXl),
        ("layout.sm", QeetrixSpace.layoutSm), ("layout.md", QeetrixSpace.layoutMd), ("layout.lg", QeetrixSpace.layoutLg),
        ("layout.xl", QeetrixSpace.layoutXl),
    ]

    private var space: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
            ForEach(Self.space, id: \.0) { name, value in
                HStack(spacing: QeetrixSpace.gapSm) {
                    Rectangle().fill(QeetrixColor.bgNeutralBold).frame(width: value, height: 8)
                    caption("space.\(name) · \(Int(value)) pt")
                }
            }
        }
    }

    private static let radii: [(String, CGFloat)] = [
        ("none", QeetrixRadius.none), ("sm", QeetrixRadius.sm), ("tooltip", QeetrixRadius.tooltip),
        ("control", QeetrixRadius.control), ("surface", QeetrixRadius.surface), ("modal", QeetrixRadius.modal),
    ]

    private static let borders: [(String, CGFloat)] = [
        ("default", QeetrixBorderWidth.default), ("strong", QeetrixBorderWidth.strong), ("accent", QeetrixBorderWidth.accent),
    ]

    private var radiiAndBorders: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
            FlowLayout {
                ForEach(Self.radii, id: \.0) { name, radius in
                    caption("radius.\(name)")
                        .padding(QeetrixSpace.insetMd)
                        .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(QeetrixColor.borderStrong))
                }
                caption("radius.chip")
                    .padding(.horizontal, QeetrixSpace.insetMd)
                    .padding(.vertical, QeetrixSpace.insetXs)
                    .overlay(Capsule().strokeBorder(QeetrixColor.borderStrong))
            }
            ForEach(Self.borders, id: \.0) { name, width in
                HStack(spacing: QeetrixSpace.gapSm) {
                    Rectangle().fill(name == "accent" ? QeetrixColor.borderBrand : QeetrixColor.borderStrong).frame(
                        width: 64, height: width)
                    caption("border.width.\(name) · \(Int(width)) pt")
                }
            }
        }
    }

    // MARK: Shadows

    private var shadows: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
            caption("Only floating layers have shadows: menus, popovers, toasts and dialogs.")
            adaptiveRow {
                ForEach(QeetrixShadow.allCases, id: \.self) { shadow in
                    QeetrixText(shadow.rawValue.replacingOccurrences(of: "shadow.", with: ""), size: .sm, weight: .medium, tone: .default)
                        .padding(QeetrixSpace.insetLg)
                        .frame(maxWidth: .infinity)
                        .qeetrixShadow(shadow, fill: .surfaceOverlay, in: RoundedRectangle(cornerRadius: QeetrixRadius.overlay))
                }
            }
            .padding(.vertical, QeetrixSpace.gapSm)
        }
    }

    // MARK: Densities

    private var densities: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapLg) {
            ForEach(QeetrixDensity.allCases, id: \.self) { density in
                VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                    QeetrixText(density.rawValue, weight: .medium, tone: .default)
                    caption(
                        "controls \(Int(density.sizeControlSm)) / \(Int(density.sizeControlMd)) / \(Int(density.sizeControlLg)) pt · row \(Int(density.sizeRow)) pt · form gap \(Int(density.spaceFormGap)) pt"
                    )
                    HStack(spacing: QeetrixSpace.gapSm) {
                        ForEach(QeetrixControlSize.allCases, id: \.self) { size in
                            QeetrixButton(size.rawValue, variant: .soft, size: size) {}
                        }
                    }
                    .qeetrixDensity(density)
                }
            }
        }
    }

    // MARK: Motion

    private static let durations: [(String, QeetrixDuration)] = [
        ("instant", .instant), ("fast", .fast), ("normal", .normal), ("slow", .slow), ("slower", .slower),
    ]

    private var motion: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
            ForEach(Self.durations, id: \.0) { name, duration in
                caption("motion.duration.\(name) · \(Int(duration.seconds * 1000)) ms")
            }
            caption(reduceMotion ? "Reduce Motion is on: every duration is 0 ms." : "Under Reduce Motion every duration is 0 ms.")
            HStack(spacing: QeetrixSpace.gapMd) {
                QeetrixButton(isMoved ? "Move back" : "Move", variant: .ghost, size: .sm) { isMoved.toggle() }
                RoundedRectangle(cornerRadius: QeetrixRadius.sm)
                    .fill(QeetrixColor.bgBrandBold)
                    .frame(width: 16, height: 16)
                    .offset(x: isMoved ? 120 : 0)
                    .qeetrixAnimation(.standard, .normal, value: isMoved)
                    .accessibilityHidden(true)
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: Icons

    private var icons: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
            caption("Sharp on controls, round in navigation; outline by default, filled only when selected.")
            iconGrid(.sharp, .outline)
            iconGrid(.sharp, .filled)
            iconGrid(.round, .outline)
            iconGrid(.round, .filled)
            HStack(spacing: QeetrixSpace.gapMd) {
                QeetrixIcon(.lock, size: .lg, shape: .sharp, variant: .filled, label: Text("Locked"))
                    .foregroundStyle(QeetrixColor.iconBrand)
                caption("Labelled: VoiceOver reads “Locked”")
            }
            HStack(spacing: QeetrixSpace.gapMd) {
                QeetrixIcon(.send, size: .lg, shape: .sharp)
                caption("send mirrors right-to-left")
            }
            .foregroundStyle(QeetrixColor.iconDefault)
            .environment(\.layoutDirection, .rightToLeft)
        }
    }

    private func iconGrid(_ shape: QeetrixIconShape, _ variant: QeetrixIconVariant) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: iconCell), spacing: QeetrixSpace.gapSm)], alignment: .leading) {
            ForEach(QeetrixIconName.allCases.filter { $0.hasDrawing(shape, variant) }, id: \.self) { name in
                QeetrixIcon(name, shape: shape, variant: variant)
            }
        }
        .foregroundStyle(QeetrixColor.iconDefault)
    }
}

#Preview("Light") {
    FoundationsPage(mode: .constant(.light)).qeetrixTheme(.light)
}

#Preview("Dark, large text") {
    FoundationsPage(mode: .constant(.dark)).qeetrixTheme(.dark).dynamicTypeSize(.accessibility2)
}
