#if os(iOS)
    import Qeetrix
    import SnapshotTesting
    import SwiftUI
    import Testing
    import UIKit

    /// The baseline matrix of ADR 0009: every component specimen is recorded in these four
    /// configurations, and each specimen shows the component's variants and states (disabled, error,
    /// loading) side by side, rather than one image per combination.
    enum SnapshotConfiguration: String, CaseIterable {
        case light
        case dark
        /// Accessibility text size 3 (AX3), where layouts must reflow.
        case largeText = "ax3"
        case rightToLeft = "rtl"

        var colorScheme: ColorScheme { self == .dark ? .dark : .light }
        var dynamicTypeSize: DynamicTypeSize { self == .largeText ? .accessibility3 : .large }
        var layoutDirection: LayoutDirection { self == .rightToLeft ? .rightToLeft : .leftToRight }

        var traits: UITraitCollection {
            UITraitCollection { traits in
                traits.displayScale = SnapshotEnvironment.scale
                traits.userInterfaceStyle = self == .dark ? .dark : .light
                traits.preferredContentSizeCategory = self == .largeText ? .accessibilityExtraExtraExtraLarge : .large
                traits.layoutDirection = self == .rightToLeft ? .rightToLeft : .leftToRight
                traits.horizontalSizeClass = .compact
            }
        }
    }

    /// The pinned rendering environment. Baselines are only comparable when recorded under it; the
    /// tests check it before comparing, so a different simulator fails with a clear reason instead of
    /// a wall of pixel differences.
    enum SnapshotEnvironment {
        /// The simulator runtime the baselines were recorded on.
        static let runtimeMajorVersion = 27
        /// Pixels per point. 2 rather than the device's 3 keeps the baselines small; hairlines are
        /// still 2 pixels.
        static let scale: CGFloat = 2
        /// The width a specimen is laid out at: a common iPhone width.
        static let width: CGFloat = 390
        /// Tolerances for anti-aliasing differences between machines: 99.5% of pixels must match, each
        /// to 98% (about the eye's own ΔE threshold).
        static let precision: Float = 0.995
        static let perceptualPrecision: Float = 0.98
    }

    /// Records or compares `specimen` in every ``SnapshotConfiguration``, as
    /// `__Snapshots__/<Family>/<TestFile>/<test>.<configuration>.png` at the root of this target — one
    /// folder, so the package manifest excludes it once. The images stay on this machine: git ignores
    /// them (ADR 0013).
    @MainActor
    func assertSpecimen<V: View>(
        _ specimen: V,
        fileID: StaticString = #fileID,
        file filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        #expect(
            version.majorVersion == SnapshotEnvironment.runtimeMajorVersion,
            "Baselines were recorded on iOS \(SnapshotEnvironment.runtimeMajorVersion); this is iOS \(version.majorVersion).")
        UIView.setAnimationsEnabled(false)
        let testFile = URL(fileURLWithPath: "\(filePath)")
        let directory = testFile.deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__")
            .appendingPathComponent(testFile.deletingLastPathComponent().lastPathComponent)
            .appendingPathComponent(testFile.deletingPathExtension().lastPathComponent)
        for configuration in SnapshotConfiguration.allCases {
            let view =
                specimen
                .padding(16)
                .frame(width: SnapshotEnvironment.width, alignment: .topLeading)
                .background(QeetrixColor.surfaceCanvas)
                .environment(\.colorScheme, configuration.colorScheme)
                .environment(\.dynamicTypeSize, configuration.dynamicTypeSize)
                .environment(\.layoutDirection, configuration.layoutDirection)
                // Pinned in the environment as well as the traits: the size pass and the drawing pass
                // must agree, or a size-class-dependent view is measured at one size and drawn at another.
                .environment(\.horizontalSizeClass, .compact)
                .environment(\.locale, Locale(identifier: "en_US"))
                .transaction { $0.disablesAnimations = true }
            let failure = verifySnapshot(
                of: view,
                as: .image(
                    precision: SnapshotEnvironment.precision, perceptualPrecision: SnapshotEnvironment.perceptualPrecision,
                    layout: .sizeThatFits,
                    traits: configuration.traits),
                named: configuration.rawValue,
                snapshotDirectory: directory.path,
                fileID: fileID, file: filePath, testName: testName, line: line, column: column
            )
            if let failure {
                Issue.record(
                    Comment(rawValue: failure),
                    sourceLocation: SourceLocation(
                        fileID: "\(fileID)", filePath: "\(filePath)", line: Int(line), column: Int(column)))
            }
        }
    }

    /// Lays out children left to right (right to left under RTL), wrapping onto new lines — so a row
    /// of badges or buttons reflows at large text sizes as it would in an app.
    struct FlowLayout: Layout {
        var spacing: CGFloat = 8

        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
            arrange(subviews, width: proposal.width ?? .infinity).size
        }

        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            for (index, origin) in arrange(subviews, width: bounds.width).origins.enumerated() {
                subviews[index].place(at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y), proposal: .unspecified)
            }
        }

        private func arrange(_ subviews: Subviews, width: CGFloat) -> (origins: [CGPoint], size: CGSize) {
            var origins: [CGPoint] = []
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxX: CGFloat = 0
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x > 0 && x + size.width > width {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                origins.append(CGPoint(x: x, y: y))
                x += size.width + spacing
                maxX = max(maxX, x - spacing)
                lineHeight = max(lineHeight, size.height)
            }
            return (origins, CGSize(width: maxX, height: y + lineHeight))
        }
    }
#endif
