import CoreGraphics
import Foundation
import SwiftUI

/// The repository the tests run from. Parity tests read the upstream snapshot directly, so they check
/// the generated Swift against `@qeetrix/tokens`' own artifacts rather than against themselves.
enum Repository {
    static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

    static func data(_ path: String) throws -> Data {
        try Data(contentsOf: root.appendingPathComponent(path))
    }

    static func json(_ path: String) throws -> Any {
        try JSONSerialization.jsonObject(with: try data(path))
    }

    /// One token of a pre-resolved DTCG file: its `$type` (own or inherited) and its `$value` with every
    /// `{alias}` followed.
    struct DTCGToken {
        let type: String
        let value: Any
        /// `$extensions["in.qeet.qeetrix"]` as written (its aliases are not followed).
        var qeetrix: [String: Any]? = nil
    }

    /// `Upstream/qeetrix-tokens/dtcg/<scheme>.tokens.json` — the package's own resolution of a colour
    /// scheme at the default density — flattened by dotted path, aliases followed.
    static func dtcg(_ scheme: String) throws -> [String: DTCGToken] {
        let root = try json("Upstream/qeetrix-tokens/dtcg/\(scheme).tokens.json") as? [String: Any] ?? [:]
        var raw: [String: (type: String?, value: Any)] = [:]
        var extensions: [String: [String: Any]] = [:]
        func walk(_ node: [String: Any], _ path: [String], _ type: String?) {
            let type = node["$type"] as? String ?? type
            if let value = node["$value"] {
                raw[path.joined(separator: ".")] = (type, value)
                extensions[path.joined(separator: ".")] = (node["$extensions"] as? [String: Any])?["in.qeet.qeetrix"] as? [String: Any]
                return
            }
            for (key, child) in node where !key.hasPrefix("$") {
                if let child = child as? [String: Any] { walk(child, path + [key], type) }
            }
        }
        walk(root, [], nil)
        func resolve(_ value: Any) -> Any {
            if let text = value as? String, text.hasPrefix("{"), text.hasSuffix("}") {
                return resolve(raw[String(text.dropFirst().dropLast())]?.value ?? text)
            }
            if let object = value as? [String: Any] { return object.mapValues(resolve) }
            if let array = value as? [Any] { return array.map(resolve) }
            return value
        }
        func type(_ key: String) -> String {
            if let type = raw[key]?.type { return type }
            if let text = raw[key]?.value as? String, text.hasPrefix("{") { return type(String(text.dropFirst().dropLast())) }
            return ""
        }
        return Dictionary(
            uniqueKeysWithValues: raw.keys.map {
                ($0, DTCGToken(type: type($0), value: resolve(raw[$0]!.value), qeetrix: extensions[$0]))
            })
    }

    /// A DTCG `{ value, unit }` dimension in points (1 px = 1 pt, 1 rem = 16 pt).
    static func points(_ value: Any?) -> Double? {
        guard let object = value as? [String: Any], let amount = object["value"] as? Double, let unit = object["unit"] as? String
        else { return nil }
        return unit == "rem" ? amount * 16 : amount
    }

    /// `docs/token-values.json`'s tokens, keyed by path.
    static func tokenValues() throws -> [String: [String: Any]] {
        let root = try json("docs/token-values.json") as? [String: Any] ?? [:]
        let tokens = root["tokens"] as? [[String: Any]] ?? []
        return Dictionary(uniqueKeysWithValues: tokens.compactMap { token in (token["path"] as? String).map { ($0, token) } })
    }

    /// The custom properties `tokens.css` declares directly in a block such as `:root` or
    /// `[data-qx-density="compact"]`, and inside `@media (prefers-reduced-motion: reduce)`.
    static func stylesheet(block: String, inside media: String? = nil) throws -> [String: String] {
        var css = String(decoding: try data("Upstream/qeetrix-tokens/tokens.css"), as: UTF8.self)
        if let media {
            guard let start = css.range(of: media) else { return [:] }
            css = String(css[start.upperBound...])
        } else if let media = css.range(of: "@media") {
            css = String(css[..<media.lowerBound])
        }
        guard let start = css.range(of: block + " {") else { return [:] }
        let body = css[start.upperBound...].prefix { $0 != "}" }
        var result: [String: String] = [:]
        for line in body.split(separator: ";") {
            let parts = line.split(separator: ":", maxSplits: 1)
            guard parts.count == 2 else { continue }
            let name = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            if name.hasPrefix("--qx-") { result[name] = parts[1].trimmingCharacters(in: .whitespacesAndNewlines) }
        }
        return result
    }

    /// `#rrggbb` → 0–255 channels.
    static func bytes(_ hex: String) -> (r: Int, g: Int, b: Int) {
        let digits = Array(hex.dropFirst())
        func channel(_ index: Int) -> Int { Int(String(digits[index...index + 1]), radix: 16) ?? -1 }
        return (channel(0), channel(2), channel(4))
    }
}

/// An 8-bit sRGB rendering of a view, for checking what was actually drawn.
struct Rendered {
    let width: Int
    let height: Int
    private let bytes: [UInt8]

    @MainActor
    init?<V: View>(_ view: V) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        guard let image = renderer.cgImage, let space = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        let width = image.width
        let height = image.height
        var buffer = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = buffer.withUnsafeMutableBytes { pointer -> Bool in
            guard
                let context = CGContext(
                    data: pointer.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                    space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return nil }
        self.width = width
        self.height = height
        bytes = buffer
    }

    /// RGBA, 0–255, premultiplied; `y` counts from the top (a bitmap context stores the top row first).
    func pixel(_ x: Int, _ y: Int) -> (r: Int, g: Int, b: Int, a: Int) {
        let index = (y * width + x) * 4
        return (Int(bytes[index]), Int(bytes[index + 1]), Int(bytes[index + 2]), Int(bytes[index + 3]))
    }
}

extension Color.Resolved {
    /// 0–255 sRGB components, for comparing with rendered pixels.
    var bytes: (r: Int, g: Int, b: Int) {
        func byte(_ value: Float) -> Int { Int((min(max(value, 0), 1) * 255).rounded()) }
        return (byte(red), byte(green), byte(blue))
    }

    /// `#RRGGBB` of the sRGB rendition.
    var hex: String {
        String(format: "#%02X%02X%02X", bytes.r, bytes.g, bytes.b)
    }
}

func close(_ a: (r: Int, g: Int, b: Int), _ b: (r: Int, g: Int, b: Int, a: Int), tolerance: Int = 3) -> Bool {
    abs(a.r - b.r) <= tolerance && abs(a.g - b.g) <= tolerance && abs(a.b - b.b) <= tolerance
}

/// An environment with a colour scheme, for resolving colours outside a view.
func environment(_ scheme: ColorScheme, contrast: ColorSchemeContrast = .standard) -> EnvironmentValues {
    var values = EnvironmentValues()
    values.colorScheme = scheme
    values._colorSchemeContrast = contrast
    return values
}
