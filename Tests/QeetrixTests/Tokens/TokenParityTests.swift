import Foundation
import SwiftUI
import Testing

@testable import Qeetrix

/// The generated Swift against the pinned upstream artifacts it was generated from.
@Suite("Token parity with @qeetrix/ui")
struct TokenParityTests {
    @Test("Every consumable colour has a QeetrixColor case, and no case is anything else")
    func colours() throws {
        let consumable = try Repository.consumableNames().filter { $0.hasPrefix("--qx-color-") }
        let generated = Set(QeetrixColor.allCases.map { "--qx-" + $0.rawValue.replacingOccurrences(of: ".", with: "-") })
        #expect(generated == consumable)
        #expect(QeetrixColor.allCases.count == consumable.count)
    }

    @Test("No palette primitive is reachable as a QeetrixColor")
    func noPrimitives() throws {
        let tokens = try Repository.upstreamTokens()["light"] ?? [:]
        let consumable = try Repository.consumableNames()
        let primitives = tokens.keys.filter {
            $0.hasPrefix("color.") && !consumable.contains("--qx-" + $0.replacingOccurrences(of: ".", with: "-"))
        }
        #expect(!primitives.isEmpty)
        for path in primitives { #expect(QeetrixColor(rawValue: path) == nil, "\(path) is a primitive") }
    }

    @Test("Every typography role matches its tokens.json values")
    func typography() throws {
        let tokens = try Repository.upstreamTokens()["light"] ?? [:]
        let roles = Set(tokens.keys.filter { $0.hasPrefix("typography.") }.map { $0.split(separator: ".")[1] }.map(String.init))
        #expect(Set(QeetrixTextRole.allCases.map(\.rawValue)) == roles)
        for role in QeetrixTextRole.allCases {
            let prefix = "typography.\(role.rawValue)."
            let spec = role.tokens
            #expect(Double(tokens[prefix + "font-weight"] ?? "") == spec.weight.value)
            #expect(Double(tokens[prefix + "line-height"] ?? "") == spec.lineHeight)
            let size = tokens[prefix + "font-size"] ?? ""
            let points = size.hasSuffix("rem") ? Double(size.dropLast(3))! * 16 : Double(size.dropLast(2))!
            #expect(abs(Double(spec.size) - points) < 1e-9, "\(role)")
            if let geometry = tokens[prefix + "font-geometry"] {
                #expect(Double(geometry) == spec.geometry?.value)
            } else {
                #expect(spec.geometry == nil)
            }
            let family = tokens[prefix + "font-family"] ?? ""
            #expect(family.hasPrefix("\"\(spec.family.face.webFamily)\""))
        }
    }

    @Test("Scales match tokens.json")
    func scales() throws {
        let tokens = try Repository.upstreamTokens()["light"] ?? [:]
        #expect(tokens["space.l"] == "16px" && QeetrixSpacing.l == 16)
        #expect(tokens["space.2xl"] == "32px" && QeetrixSpacing.xl2 == 32)
        #expect(tokens["icon.size.md"] == "20px" && QeetrixIconSize.md.points == 20)
        #expect(tokens["icon.stroke.regular"] == "2" && QeetrixIconStroke.regular.width == 2)
        #expect(tokens["motion.duration.fast"] == "150ms" && QeetrixDuration.fast.seconds == 0.15)
        #expect(tokens["state.opacity.disabled"] == "0.5" && QeetrixOpacity.disabled == 0.5)
        #expect(tokens["focus.ring-width"] == "3px" && QeetrixFocus.ringWidth == 3)
        #expect(tokens["density.control-height.default"] == "2rem" && QeetrixDensity.default.controlHeight == 32)
        // corner.surface is var(--radius-xl) = calc(0.45rem * 1.4) in the web's index.css.
        #expect(tokens["corner.surface"] == "var(--radius-xl)" && abs(QeetrixCorner.surface - 10.08) < 1e-9)
        #expect(QeetrixFontWeight.scale.map(\.value) == [400, 500, 600, 700])
    }

    @Test("The bundled provenance names the pinned upstream artifacts")
    func provenance() throws {
        let provenance = try QeetrixProvenance.bundled()
        let lock = try JSONSerialization.jsonObject(with: try Repository.data("Scripts/Upstream/upstream.lock.json")) as? [String: Any]
        let ui = lock?["qeetrixUI"] as? [String: String]
        #expect(provenance.tokens.package == "@qeetrix/ui")
        #expect(provenance.tokens.version == ui?["version"])
        #expect(provenance.tokens.gitHead == ui?["gitHead"])
        #expect(provenance.tokens.themes == ["light", "dark"])
        #expect(provenance.fonts.map(\.family).sorted() == QeetrixFontFamily.allCases.map(\.rawValue).sorted())
    }
}
