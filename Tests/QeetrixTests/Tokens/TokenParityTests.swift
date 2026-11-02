import Foundation
import SwiftUI
import Testing

@testable import Qeetrix

/// The generated Swift against the pinned `@qeetrix/tokens` artifacts it was generated from: the
/// package's own pre-resolved colour schemes, its stylesheet, and the lock.
@Suite("Token parity with @qeetrix/tokens")
struct TokenParityTests {
    @Test("Every color.* token has a QeetrixColor case, and no case is anything else")
    func colours() throws {
        let light = try Repository.dtcg("light")
        let paths = Set(light.keys.filter { $0.hasPrefix("color.") })
        #expect(Set(QeetrixColor.allCases.map(\.rawValue)) == paths)
        #expect(QeetrixColor.allCases.count == paths.count)
        #expect(!light.keys.contains { $0.hasPrefix("primitive.color.") && QeetrixColor(rawValue: $0) != nil }, "No primitive is reachable")
    }

    @Test("Every colour resolves to the package's own hex in both schemes", arguments: ["light", "dark"])
    func hexes(scheme: String) throws {
        let tokens = try Repository.dtcg(scheme)
        let values = environment(scheme == "dark" ? .dark : .light)
        for color in QeetrixColor.allCases {
            let value = try #require(tokens[color.rawValue]?.value as? [String: Any], "\(color)")
            let hex = try #require(value["hex"] as? String)
            let resolved = color.resolve(in: values)
            let alpha = value["alpha"] as? Double ?? 1
            #expect(abs(Double(resolved.opacity) - alpha) < 0.002, "\(color) alpha")
            // Display P3 colours are drawn outside sRGB; their sRGB hex is the clipped rendition.
            guard color.rgba(for: values.colorScheme).space == .sRGB else { continue }
            let expected = Repository.bytes(hex)
            let actual = resolved.bytes
            #expect(
                abs(expected.r - actual.r) <= 1 && abs(expected.g - actual.g) <= 1 && abs(expected.b - actual.b) <= 1,
                "\(color) (\(scheme)): \(resolved.hex) vs \(hex)")
        }
    }

    @Test("Every typography role matches its DTCG value")
    func typography() throws {
        let tokens = try Repository.dtcg("light")
        let roles = Set(tokens.keys.filter { $0.hasPrefix("typography.") }.map { String($0.dropFirst("typography.".count)) })
        #expect(Set(QeetrixTextRole.allCases.map(\.rawValue)) == roles)
        #expect(QeetrixTextRole.allCases.count == 18)
        for role in QeetrixTextRole.allCases {
            let value = try #require(tokens["typography.\(role.rawValue)"]?.value as? [String: Any])
            let spec = role.tokens
            #expect(Repository.points(value["fontSize"]) == Double(spec.size), "\(role) size")
            #expect(value["fontWeight"] as? Double == spec.weight.value, "\(role) weight")
            #expect(value["lineHeight"] as? Double == spec.lineHeight, "\(role) line height")
            // The exact length and the letter style, from the role's extension.
            let qeetrix = try #require(tokens["typography.\(role.rawValue)"]?.qeetrix, "\(role) extension")
            #expect(Repository.points(qeetrix["lineHeight"]) == Double(spec.size) * spec.lineHeight, "\(role) line height length")
            let geometry = try #require(qeetrix["fontGeometry"] as? String, "\(role) font geometry")
            let position = tokens[String(geometry.dropFirst().dropLast())]?.value as? Double
            #expect(position == spec.geometry.map(\.value) ?? (spec.family == .mono ? 0 : nil), "\(role) letter style")
            #expect(Repository.points(value["letterSpacing"]) == spec.letterSpacing, "\(role) letter spacing")
            let family = (value["fontFamily"] as? [String])?.first
            #expect(family == spec.family.face.webFamily, "\(role) family")
        }
    }

    @Test("Densities match tokens.css for every density")
    func densities() throws {
        func points(_ css: String?) -> CGFloat? {
            guard let css else { return nil }
            if css.hasSuffix("rem") { return CGFloat(Double(css.dropLast(3))! * 16) }
            if css.hasSuffix("px") { return CGFloat(Double(css.dropLast(2))!) }
            return nil
        }
        for density in QeetrixDensity.allCases {
            let block = try Repository.stylesheet(block: "[data-qx-density=\"\(density.rawValue)\"]")
            #expect(points(block["--qx-size-control-sm"]) == density.sizeControlSm, "\(density)")
            #expect(points(block["--qx-size-control-md"]) == density.sizeControlMd, "\(density)")
            #expect(points(block["--qx-size-control-lg"]) == density.sizeControlLg, "\(density)")
            #expect(points(block["--qx-size-row"]) == density.sizeRow, "\(density)")
            #expect(points(block["--qx-space-form-gap"]) == density.spaceFormGap, "\(density)")
        }
        // Design rules §6: compact 24/28/32, default 28/32/40, comfortable 32/36/44.
        #expect(QeetrixControlSize.allCases.map(QeetrixDensity.compact.controlHeight) == [24, 28, 32])
        #expect(QeetrixControlSize.allCases.map(QeetrixDensity.default.controlHeight) == [28, 32, 40])
        #expect(QeetrixControlSize.allCases.map(QeetrixDensity.comfortable.controlHeight) == [32, 36, 44])
    }

    @Test("Scales match the DTCG build")
    func scales() throws {
        let tokens = try Repository.dtcg("light")
        func points(_ path: String) -> Double? { Repository.points(tokens[path]?.value) }
        #expect(points("space.inset.lg") == 16 && QeetrixSpace.insetLg == 16)
        #expect(points("space.layout.md") == 32 && QeetrixSpace.layoutMd == 32)
        #expect(points("size.icon.2xs") == 12 && QeetrixIconSize.xs2.points == 12)
        #expect(points("size.icon.md") == 20 && QeetrixIconSize.md.points == 20)
        #expect(points("size.target.min") == 24 && QeetrixSize.targetMin == 24)
        #expect(points("radius.control") == 4 && QeetrixRadius.control == 4)
        #expect(points("radius.sm") == 2 && QeetrixRadius.sm == 2)
        #expect(points("border.width.accent") == 3 && QeetrixBorderWidth.accent == 3)
        #expect(points("focus.ring.width") == 2 && QeetrixFocus.ringWidth == 2)
        #expect(tokens["icon.stroke.regular"]?.value as? Double == 2 && QeetrixIconStroke.regular.width == 2)
        #expect(tokens["opacity.disabled"]?.value as? Double == 0.4 && QeetrixOpacity.disabled == 0.4)
        let fast = tokens["motion.duration.fast"]?.value as? [String: Any]
        #expect(fast?["value"] as? Double == 100 && QeetrixDuration.fast.seconds == 0.1)
        #expect(tokens["motion.easing.standard"]?.value as? [Double] == [0.65, 0, 0.35, 1])
        #expect(QeetrixEasing.standard == QeetrixEasing(0.65, 0, 0.35, 1))
        #expect(tokens["motion.spring.snappy.stiffness"]?.value as? Double == QeetrixSpring.snappy.stiffness)
        #expect(QeetrixFontWeight.scale.map(\.value) == [400, 500, 600])
        #expect(QeetrixFontGeometry.display.value == 100 && QeetrixFontGeometry.heading.value == 50 && QeetrixFontGeometry.body.value == 0)
    }

    @Test("Reduce Motion takes tokens.css's reduced-motion block: every duration 0 ms")
    func reducedMotion() throws {
        let reduced = try Repository.stylesheet(block: ":root", inside: "@media (prefers-reduced-motion: reduce)")
        #expect(!reduced.isEmpty)
        for name in ["instant", "fast", "normal", "slow", "slower"] {
            #expect(reduced["--qx-motion-duration-\(name)"] == "0ms", "\(name)")
        }
        #expect(QeetrixMotion.reducedDuration.seconds == 0)
    }

    @Test("token-values.json lists every generated colour with the value iOS draws")
    func tokenValues() throws {
        let values = try Repository.tokenValues()
        for color in QeetrixColor.allCases {
            let entry = try #require(values[color.rawValue], "\(color)")
            #expect(entry["swift"] as? String == "QeetrixColor.\(color)")
            #expect(entry["varies"] as? String != "density")
        }
        #expect(values["size.control.lg"]?["varies"] as? String == "density")
        #expect(values["size.control.lg"]?["swift"] as? String == "QeetrixDensity.sizeControlLg")
    }

    @Test("The bundled provenance names the three pinned packages")
    func provenance() throws {
        let provenance = try QeetrixProvenance.bundled()
        let lock = try Repository.json("Upstream/upstream.lock.json") as? [String: Any]
        let packages = (lock?["packages"] as? [[String: String]]) ?? []
        func locked(_ name: String) -> [String: String]? { packages.first { $0["package"] == name } }
        #expect(provenance.tokens.package == "@qeetrix/tokens")
        #expect(provenance.tokens.version == locked("@qeetrix/tokens")?["version"])
        #expect(provenance.tokens.gitHead == locked("@qeetrix/tokens")?["gitHead"])
        #expect(provenance.icons.package == "@qeetrix/icons")
        #expect(provenance.icons.version == locked("@qeetrix/icons")?["version"])
        #expect(provenance.components.package == "@qeetrix/react")
        #expect(provenance.components.version == locked("@qeetrix/react")?["version"])
        #expect(provenance.tokens.colorSchemes == ["light", "dark"])
        #expect(provenance.tokens.densities.first == "default")
        #expect(provenance.fonts.map(\.family).sorted() == QeetrixFontFamily.allCases.map(\.rawValue).sorted())
        #expect(provenance.fonts.allSatisfy { $0.package == "@qeetrix/tokens" && $0.source.hasSuffix(".ttf") })
    }
}
