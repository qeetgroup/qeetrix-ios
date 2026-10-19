import CoreGraphics
import Foundation
import SwiftUI

/// The repository the tests run from. Parity tests read the upstream snapshot directly, so they check
/// the generated Swift against qeetrix-ui's own artifacts rather than against themselves.
enum Repository {
    static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

    static func data(_ path: String) throws -> Data {
        try Data(contentsOf: root.appendingPathComponent(path))
    }

    /// `tokens.json` from the pinned `@qeetrix/ui`, flattened per theme: `"color.text.primary" → "oklch(…)"`.
    static func upstreamTokens() throws -> [String: [String: String]] {
        let json = try JSONSerialization.jsonObject(with: try data("Upstream/qeetrix-ui/tokens.json")) as? [String: Any] ?? [:]
        var result: [String: [String: String]] = [:]
        for theme in ["light", "dark"] {
            var flat: [String: String] = [:]
            func walk(_ node: Any, _ path: [String]) {
                if let object = node as? [String: Any] {
                    for (key, child) in object where !key.hasPrefix("$") { walk(child, path + [key]) }
                } else {
                    flat[path.joined(separator: ".")] = "\(node)"
                }
            }
            walk(json[theme] ?? [:], [])
            result[theme] = flat
        }
        return result
    }

    /// The `--qx-*` names `tokens.css` declares on `:root` — upstream's consumable layer.
    static func consumableNames() throws -> Set<String> {
        let css = String(decoding: try data("Upstream/qeetrix-ui/tokens.css"), as: UTF8.self)
        let regex = try NSRegularExpression(pattern: "(--qx-[a-z0-9-]+):")
        var names: Set<String> = []
        for block in css.components(separatedBy: ":root {").dropFirst() {
            let body = block.components(separatedBy: "}").first ?? ""
            for match in regex.matches(in: body, range: NSRange(body.startIndex..., in: body)) {
                names.insert(String(body[Range(match.range(at: 1), in: body)!]))
            }
        }
        return names
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
}

func close(_ a: (r: Int, g: Int, b: Int), _ b: (r: Int, g: Int, b: Int, a: Int), tolerance: Int = 3) -> Bool {
    abs(a.r - b.r) <= tolerance && abs(a.g - b.g) <= tolerance && abs(a.b - b.b) <= tolerance
}
