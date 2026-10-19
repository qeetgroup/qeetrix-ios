import Qeetrix
import SwiftUI

/// The foundations on one page: theme switching, colours in both themes, typography roles with Dynamic
/// Type, spacing, corners, elevation and icons. Built only from the public Qeetrix API, and laid out to
/// stay readable at every text size: rows fall back to stacks when they do not fit.
struct FoundationsPage: View {
    @Binding var mode: QeetrixThemeMode
    @State private var typeSize: DynamicTypeSize = .large
    @ScaledMetric(relativeTo: .body) private var iconCell: CGFloat = 32

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: QeetrixSpacing.xl2) {
                    header
                    section("Theme") { themePicker }
                    section("Colours") { colours }
                    section("Typography") { typography }
                    section("Spacing and corners") { spacingAndCorners }
                    section("Elevation") { elevation }
                    section("Icons") { icons }
                }
                .padding(QeetrixSpacing.l)
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
        VStack(alignment: .leading, spacing: QeetrixSpacing.xs) {
            Text("Qeetrix")
                .qeetrixTextStyle(.display)
                .foregroundStyle(QeetrixColor.textBrandDisplay)
            Text("Foundations from @qeetrix/ui \((try? QeetrixProvenance.bundled().tokens.version) ?? "?")")
                .qeetrixTextStyle(.body)
                .foregroundStyle(QeetrixColor.textSecondary)
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: QeetrixSpacing.m) {
            Text(title)
                .qeetrixTextStyle(.heading)
                .foregroundStyle(QeetrixColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            content()
        }
        .id(title.lowercased().components(separatedBy: " ").first ?? title)
    }

    /// Side by side when there is room, stacked when there is not (large text, narrow screens).
    private func adaptiveRow<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: QeetrixSpacing.m) { content() }
            VStack(alignment: .leading, spacing: QeetrixSpacing.m) { content() }
        }
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

    private static let swatches: [QeetrixColor] = [
        .surfaceDefault, .surfaceSubtle, .textPrimary, .textSecondary, .textBrand, .actionPrimary,
        .feedbackSuccess, .feedbackWarning, .feedbackError, .feedbackInfo, .borderDefault, .focusRing,
    ]

    private var colours: some View {
        adaptiveRow {
            palette("Light").qeetrixTheme(.light)
            palette("Dark").qeetrixTheme(.dark)
        }
    }

    private func palette(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: QeetrixSpacing.xs) {
            Text(title).qeetrixTextStyle(.label).foregroundStyle(QeetrixColor.textPrimary)
            ForEach(Self.swatches, id: \.self) { color in
                HStack(spacing: QeetrixSpacing.s) {
                    RoundedRectangle(cornerRadius: QeetrixCorner.chip)
                        .fill(color)
                        .frame(width: 28, height: 28)
                        .overlay(RoundedRectangle(cornerRadius: QeetrixCorner.chip).stroke(QeetrixColor.borderSubtle))
                        .accessibilityHidden(true)
                    Text(color.rawValue.replacingOccurrences(of: "color.", with: ""))
                        .qeetrixTextStyle(.caption)
                        .foregroundStyle(QeetrixColor.textSecondary)
                }
            }
        }
        .padding(QeetrixSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .qeetrixElevation(.flat, fill: .surfaceDefault, in: RoundedRectangle(cornerRadius: QeetrixCorner.surface))
    }

    // MARK: Typography

    private var typography: some View {
        VStack(alignment: .leading, spacing: QeetrixSpacing.m) {
            Picker("Preview text size", selection: $typeSize) {
                ForEach([DynamicTypeSize.small, .large, .xxxLarge, .accessibility3], id: \.self) { size in
                    Text(String(describing: size)).tag(size)
                }
            }
            .pickerStyle(.menu)
            VStack(alignment: .leading, spacing: QeetrixSpacing.s) {
                ForEach(QeetrixTextRole.allCases, id: \.self) { role in
                    Text("\(role.rawValue) — the quick brown fox jumps over the lazy dog")
                        .qeetrixTextStyle(role)
                        .foregroundStyle(QeetrixColor.textPrimary)
                }
            }
            .dynamicTypeSize(typeSize)
        }
    }

    // MARK: Spacing, corners, elevation

    private static let spacing: [(String, CGFloat)] = [
        ("xs", QeetrixSpacing.xs), ("s", QeetrixSpacing.s), ("m", QeetrixSpacing.m), ("l", QeetrixSpacing.l),
        ("xl", QeetrixSpacing.xl), ("xl2", QeetrixSpacing.xl2),
    ]

    private static let corners: [(String, CGFloat)] = [
        ("chip", QeetrixCorner.chip), ("control", QeetrixCorner.control), ("surface", QeetrixCorner.surface),
    ]

    private var spacingAndCorners: some View {
        VStack(alignment: .leading, spacing: QeetrixSpacing.m) {
            ForEach(Self.spacing, id: \.0) { name, value in
                HStack(spacing: QeetrixSpacing.s) {
                    Rectangle().fill(QeetrixColor.actionPrimary).frame(width: value, height: 8)
                    Text("space.\(name) · \(Int(value)) pt")
                        .qeetrixTextStyle(.caption)
                        .foregroundStyle(QeetrixColor.textSecondary)
                }
            }
            adaptiveRow {
                ForEach(Self.corners, id: \.0) { name, radius in
                    Text("corner.\(name)")
                        .qeetrixTextStyle(.caption)
                        .foregroundStyle(QeetrixColor.textSecondary)
                        .padding(QeetrixSpacing.m)
                        .overlay(
                            RoundedRectangle(cornerRadius: radius)
                                .stroke(QeetrixColor.borderStrong, lineWidth: QeetrixStroke.hairline))
                }
            }
        }
    }

    private var elevation: some View {
        adaptiveRow {
            ForEach([QeetrixElevation.raised, .overlay, .modal], id: \.self) { level in
                Text(level.rawValue.replacingOccurrences(of: "elevation.", with: ""))
                    .qeetrixTextStyle(.label)
                    .foregroundStyle(QeetrixColor.textPrimary)
                    .padding(QeetrixSpacing.l)
                    .frame(maxWidth: .infinity)
                    .qeetrixElevation(level, fill: .surfaceElevated, in: RoundedRectangle(cornerRadius: QeetrixCorner.surface))
            }
        }
        .padding(.vertical, QeetrixSpacing.s)
    }

    // MARK: Icons

    private var icons: some View {
        VStack(alignment: .leading, spacing: QeetrixSpacing.m) {
            iconGrid(.round, .outline)
            iconGrid(.round, .filled)
            iconGrid(.sharp, .outline)
            HStack(spacing: QeetrixSpacing.m) {
                QeetrixIcon(.lock, size: .lg, variant: .filled, label: Text("Locked"))
                    .foregroundStyle(QeetrixColor.textBrand)
                Text("Labelled: VoiceOver reads “Locked”")
                    .qeetrixTextStyle(.caption)
                    .foregroundStyle(QeetrixColor.textSecondary)
            }
            HStack(spacing: QeetrixSpacing.m) {
                QeetrixIcon(.send, size: .lg)
                Text("send mirrors right-to-left").qeetrixTextStyle(.caption)
            }
            .foregroundStyle(QeetrixColor.textPrimary)
            .environment(\.layoutDirection, .rightToLeft)
        }
    }

    private func iconGrid(_ shape: QeetrixIconShape, _ variant: QeetrixIconVariant) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: iconCell), spacing: QeetrixSpacing.s)], alignment: .leading) {
            ForEach(QeetrixIconName.allCases.filter { $0.hasDrawing(shape, variant) }, id: \.self) { name in
                QeetrixIcon(name, shape: shape, variant: variant)
            }
        }
        .foregroundStyle(QeetrixColor.textPrimary)
    }
}

#Preview("Light") {
    FoundationsPage(mode: .constant(.light)).qeetrixTheme(.light)
}

#Preview("Dark, large text") {
    FoundationsPage(mode: .constant(.dark)).qeetrixTheme(.dark).dynamicTypeSize(.accessibility2)
}
