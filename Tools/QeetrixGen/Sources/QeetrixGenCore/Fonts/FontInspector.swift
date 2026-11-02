import Foundation

/// Reads the facts the library needs from a TrueType/OpenType file: its names and its variation axes.
/// The generator records these from the font itself rather than from documentation, so the
/// PostScript name the library asks CoreText for is the one the file actually carries.
public struct FontInfo: Equatable, Sendable {
    public struct Axis: Equatable, Sendable {
        public let tag: String
        public let minimum: Double
        public let defaultValue: Double
        public let maximum: Double
    }

    public let familyName: String
    public let postScriptName: String
    public let version: String
    public let axes: [Axis]
}

/// A bundled font: the pin that produced it plus what the file says about itself.
public struct FontSpec: Equatable, Sendable {
    /// The `QeetrixFontFamily` case, e.g. `sans`.
    public let family: String
    /// The family name the web's CSS uses for it, e.g. `Qeet Sans`.
    public let webFamily: String
    /// The npm package and the TTF's path in it.
    public let package: String
    public let source: String
    /// The file name without extension inside `Resources/Fonts`.
    public let resourceName: String
    public let info: FontInfo
}

public enum FontInspector {
    public static func inspect(_ data: Data, context: String) throws -> FontInfo {
        let bytes = [UInt8](data)
        func u16(_ offset: Int) throws -> Int {
            guard offset + 2 <= bytes.count else { throw GeneratorError("\(context): truncated font.") }
            return Int(bytes[offset]) << 8 | Int(bytes[offset + 1])
        }
        func u32(_ offset: Int) throws -> UInt32 {
            guard offset + 4 <= bytes.count else { throw GeneratorError("\(context): truncated font.") }
            return UInt32(bytes[offset]) << 24 | UInt32(bytes[offset + 1]) << 16 | UInt32(bytes[offset + 2]) << 8
                | UInt32(bytes[offset + 3])
        }
        func fixed(_ offset: Int) throws -> Double {
            Double(Int32(bitPattern: try u32(offset))) / 65536
        }
        func tag(_ offset: Int) throws -> String {
            guard offset + 4 <= bytes.count else { throw GeneratorError("\(context): truncated font.") }
            return String(decoding: bytes[offset..<offset + 4], as: UTF8.self)
        }

        let version = try u32(0)
        guard version == 0x0001_0000 || version == 0x4F54_544F else {  // TrueType or 'OTTO'
            throw GeneratorError("\(context): not a TrueType or OpenType font (WOFF/WOFF2 are web formats).")
        }
        var tables: [String: Int] = [:]
        for index in 0..<(try u16(4)) {
            let record = 12 + index * 16
            tables[try tag(record)] = Int(try u32(record + 8))
        }

        // name: prefer Windows Unicode English, fall back to any Windows Unicode, then Mac Roman.
        guard let name = tables["name"] else { throw GeneratorError("\(context): no name table.") }
        let count = try u16(name + 2)
        let storage = name + (try u16(name + 4))
        var candidates: [Int: [(rank: Int, value: String)]] = [:]
        for index in 0..<count {
            let record = name + 6 + index * 12
            let platform = try u16(record)
            let encoding = try u16(record + 2)
            let language = try u16(record + 4)
            let id = try u16(record + 6)
            let length = try u16(record + 8)
            let offset = storage + (try u16(record + 10))
            guard offset + length <= bytes.count else { continue }
            let slice = Array(bytes[offset..<offset + length])
            if platform == 3, encoding == 1 || encoding == 10 {
                var units: [UInt16] = []
                for i in stride(from: 0, to: slice.count - 1, by: 2) { units.append(UInt16(slice[i]) << 8 | UInt16(slice[i + 1])) }
                candidates[id, default: []].append((language == 0x409 ? 0 : 1, String(decoding: units, as: UTF16.self)))
            } else if platform == 1, encoding == 0 {
                candidates[id, default: []].append((2, String(decoding: slice, as: UTF8.self)))
            }
        }
        func string(_ id: Int) -> String? {
            candidates[id]?.min { $0.rank < $1.rank }?.value
        }
        guard let postScriptName = string(6), let family = string(16) ?? string(1) else {
            throw GeneratorError("\(context): the name table has no PostScript or family name.")
        }

        var axes: [FontInfo.Axis] = []
        if let fvar = tables["fvar"] {
            let axesOffset = fvar + (try u16(fvar + 4))
            let axisCount = try u16(fvar + 8)
            let axisSize = try u16(fvar + 10)
            for index in 0..<axisCount {
                let record = axesOffset + index * axisSize
                axes.append(
                    FontInfo.Axis(
                        tag: try tag(record), minimum: try fixed(record + 4),
                        defaultValue: try fixed(record + 8), maximum: try fixed(record + 12)))
            }
        }
        return FontInfo(familyName: family, postScriptName: postScriptName, version: string(5) ?? "", axes: axes)
    }
}
