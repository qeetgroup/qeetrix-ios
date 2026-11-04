import Foundation

/// A value too long for a QR code at its level, as the web's `RangeError`.
struct QeetrixQRCodeTooLong: Error, Equatable {
    let byteCount: Int
    let level: QeetrixQRCodeLevel
}

/// The modules of a QR code (ISO/IEC 18004), row by row, `true` for dark — encoded exactly as
/// `@qeetrix/react` 0.4.0's own encoder does (`experimental/qr-code/encode.js`), so a value draws the
/// same modules on iOS as on the web:
///
/// - byte mode only (the text as UTF-8), in the smallest version 1–40 that holds it at the level, with
///   no raising of the level to fill spare room;
/// - Reed–Solomon over GF(256) (x⁸ + x⁴ + x³ + x² + 1), blocks interleaved;
/// - BCH-coded format and version information;
/// - of the eight masks, the first with the lowest penalty under the web's four rules: runs of five or
///   more (length − 2 each), 2 × 2 blocks (3 each), `10111010000` and `00001011101` inside a row or
///   column (40 each; the quiet zone isn't counted as light), and 10 per whole 5% the dark share is
///   from half.
///
/// CoreImage's `CIQRCodeGenerator` is not used: it picks its own modes and masks, so its modules differ
/// from the web's for the same value (an empty value at `L`, say, takes mask 6 there and 0 here).
struct QeetrixQRCodeMatrix: Equatable, Sendable {
    /// 1 to 40.
    let version: Int
    /// The mask pattern chosen, 0 to 7.
    let mask: Int
    /// Modules per side, without the quiet zone: `4 × version + 17`.
    let size: Int
    /// Row-major.
    let modules: [Bool]
    /// Each mask's penalty, 0 to 7.
    let penalties: [Int]

    subscript(x: Int, y: Int) -> Bool {
        modules[y * size + x]
    }

    init(_ value: String, level: QeetrixQRCodeLevel) throws(QeetrixQRCodeTooLong) {
        let bytes = Array(value.utf8)
        let l = level.index
        var version = 1
        while bytes.count > QeetrixQRCodeTables.capacity(version, l) {
            version += 1
            if version > 40 { throw QeetrixQRCodeTooLong(byteCount: bytes.count, level: level) }
        }
        let stream = Self.codewords(bytes, version: version, l: l)
        let size = version * 4 + 17
        var grid = QeetrixQRCodeGrid(size: size)
        grid.drawFunctionPatterns(version: version)
        grid.place(stream)
        var best = grid.dark
        var bestMask = 0
        var lowest = Int.max
        var penalties: [Int] = []
        let plain = grid
        for mask in 0..<8 {
            var candidate = plain
            candidate.drawFormat(QeetrixQRCodeTables.formatBits(l, mask: mask))
            candidate.apply(mask: mask)
            let score = QeetrixQRCodePenalty.score(candidate.dark, size: size)
            penalties.append(score)
            if score < lowest {
                lowest = score
                best = candidate.dark
                bestMask = mask
            }
        }
        self.version = version
        self.mask = bestMask
        self.size = size
        self.modules = best.map { $0 == 1 }
        self.penalties = penalties
    }

    /// The data and error-correction codewords in the order they're placed: mode 0100, the byte count
    /// (8 bits below version 10, 16 from it), the bytes, a terminator of up to four zeros, zeros to a
    /// whole byte, pad bytes 236 and 17 in turn; split into blocks (the short ones first), each block's
    /// Reed–Solomon remainder, then data and corrections interleaved.
    static func codewords(_ bytes: [UInt8], version: Int, l: Int) -> [Int] {
        var bits: [UInt8] = []
        func put(_ value: Int, _ length: Int) {
            for i in stride(from: length - 1, through: 0, by: -1) { bits.append(UInt8((value >> i) & 1)) }
        }
        let room = QeetrixQRCodeTables.dataCodewords(version, l) * 8
        put(4, 4)
        put(bytes.count, version < 10 ? 8 : 16)
        for byte in bytes { put(Int(byte), 8) }
        put(0, min(4, room - bits.count))
        put(0, (8 - bits.count % 8) % 8)
        var pad = 236
        while bits.count < room {
            put(pad, 8)
            pad ^= 253
        }
        var data: [Int] = []
        for start in stride(from: 0, to: bits.count, by: 8) {
            data.append(bits[start..<start + 8].reduce(0) { ($0 << 1) | Int($1) })
        }

        let count = QeetrixQRCodeTables.blocks[l][version]
        let degree = QeetrixQRCodeTables.eccPerBlock[l][version]
        let total = QeetrixQRCodeTables.codewords(version)
        let short = total / count - degree
        let longs = total % count
        var parts: [[Int]] = []
        var at = 0
        for block in 0..<count {
            let length = short + (block >= count - longs ? 1 : 0)
            parts.append(Array(data[at..<at + length]))
            at += length
        }
        let fixes = parts.map { QeetrixQRCodeReedSolomon.remainder($0, degree: degree) }
        var stream: [Int] = []
        for i in 0...short {
            for part in parts where i < part.count { stream.append(part[i]) }
        }
        for i in 0..<degree {
            for fix in fixes { stream.append(fix[i]) }
        }
        return stream
    }
}

/// The symbol being built: each module's colour, and whether a function pattern owns it.
struct QeetrixQRCodeGrid: Equatable {
    let size: Int
    var dark: [UInt8]
    var reserved: [Bool]

    init(size: Int) {
        self.size = size
        dark = Array(repeating: 0, count: size * size)
        reserved = Array(repeating: false, count: size * size)
    }

    mutating func set(_ x: Int, _ y: Int, _ on: Bool) {
        dark[y * size + x] = on ? 1 : 0
        reserved[y * size + x] = true
    }

    /// Timing patterns, the three finders with their separators, the alignment patterns, the format
    /// area (reserved with zeros, and the dark module) and, from version 7, the version information.
    mutating func drawFunctionPatterns(version: Int) {
        for i in 0..<size {
            set(6, i, i % 2 == 0)
            set(i, 6, i % 2 == 0)
        }
        for (cx, cy) in [(3, 3), (size - 4, 3), (3, size - 4)] {
            for dy in -4...4 {
                for dx in -4...4 {
                    let distance = max(abs(dx), abs(dy))
                    let x = cx + dx
                    let y = cy + dy
                    if x >= 0 && x < size && y >= 0 && y < size { set(x, y, distance != 2 && distance != 4) }
                }
            }
        }
        let centres = QeetrixQRCodeTables.alignment(version, size: size)
        let last = centres.count - 1
        for (i, ay) in centres.enumerated() {
            for (j, ax) in centres.enumerated() {
                if (i == 0 && (j == 0 || j == last)) || (i == last && j == 0) { continue }
                for dy in -2...2 {
                    for dx in -2...2 { set(ax + dx, ay + dy, max(abs(dx), abs(dy)) != 1) }
                }
            }
        }
        drawFormat(0)
        if version >= 7 {
            let word = QeetrixQRCodeTables.versionBits(version)
            for i in 0..<18 {
                let a = size - 11 + i % 3
                let b = i / 3
                let on = (word >> i) & 1 == 1
                set(a, b, on)
                set(b, a, on)
            }
        }
    }

    /// Both copies of the 15-bit format word, least significant bit first, and the dark module.
    mutating func drawFormat(_ word: Int) {
        func bit(_ i: Int) -> Bool { (word >> i) & 1 == 1 }
        for i in 0...5 { set(8, i, bit(i)) }
        set(8, 7, bit(6))
        set(8, 8, bit(7))
        set(7, 8, bit(8))
        for i in 9..<15 { set(14 - i, 8, bit(i)) }
        for i in 0..<8 { set(size - 1 - i, 8, bit(i)) }
        for i in 8..<15 { set(8, size - 15 + i, bit(i)) }
        set(8, size - 8, true)
    }

    /// The codewords' bits, most significant first, in two-module columns zigzagging from the
    /// bottom-right corner and skipping the vertical timing column; leftover modules stay light.
    mutating func place(_ stream: [Int]) {
        var i = 0
        var right = size - 1
        while right >= 1 {
            if right == 6 { right = 5 }
            for vertical in 0..<size {
                for j in 0..<2 {
                    let x = right - j
                    let y = ((right + 1) & 2) == 0 ? size - 1 - vertical : vertical
                    if !reserved[y * size + x] && i < stream.count * 8 {
                        dark[y * size + x] = UInt8((stream[i >> 3] >> (7 - (i & 7))) & 1)
                        i += 1
                    }
                }
            }
            right -= 2
        }
    }

    /// Inverts every data module the mask pattern selects.
    mutating func apply(mask: Int) {
        for y in 0..<size {
            for x in 0..<size where !reserved[y * size + x] && QeetrixQRCodeTables.masks(mask, x: x, y: y) {
                dark[y * size + x] ^= 1
            }
        }
    }
}

/// The web encoder's tables and BCH codes, indexed `[level][version]` with level L, M, Q, H = 0…3 and
/// an unused version 0.
enum QeetrixQRCodeTables {
    /// The two format bits of L, M, Q, H.
    static let format = [1, 0, 3, 2]

    /// Error-correction codewords per block (`ECC_PER_BLOCK`).
    static let eccPerBlock = table([
        "7 10 15 20 26 18 20 24 30 18 20 24 26 30 22 24 28 30 28 28 28 28 30 30 26 28 30 30 30 30 30 30 30 30 30 30 30 30 30 30",
        "10 16 26 18 24 16 18 22 22 26 30 22 22 24 24 28 28 26 26 26 26 28 28 28 28 28 28 28 28 28 28 28 28 28 28 28 28 28 28 28",
        "13 22 18 26 18 24 18 22 20 24 28 26 24 20 30 24 28 28 26 30 28 30 30 30 30 28 30 30 30 30 30 30 30 30 30 30 30 30 30 30",
        "17 28 22 16 22 28 26 26 24 28 24 28 22 24 24 30 28 28 26 28 30 24 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30",
    ])

    /// Error-correction blocks (`BLOCKS`).
    static let blocks = table([
        "1 1 1 1 1 2 2 2 2 4 4 4 4 4 6 6 6 6 7 8 8 9 9 10 12 12 12 13 14 15 16 17 18 19 19 20 21 22 24 25",
        "1 1 1 2 2 4 4 4 5 5 5 8 9 9 10 10 11 13 14 16 17 17 18 20 21 23 25 26 28 29 31 33 35 37 38 40 43 45 47 49",
        "1 1 2 2 4 4 6 6 8 8 8 10 12 16 12 17 16 18 21 20 23 23 25 27 29 34 34 35 38 40 43 45 48 51 53 56 59 62 65 68",
        "1 1 2 4 4 4 5 6 8 8 11 11 16 16 18 16 19 21 25 25 25 34 30 32 35 37 40 42 45 48 51 54 57 60 63 66 70 74 77 81",
    ])

    /// Rows of 40 numbers, versions 1 to 40, each given a leading 0 so a version indexes its own
    /// column (`table` in encode.js).
    static func table(_ rows: [String]) -> [[Int]] {
        rows.map { [0] + $0.split(separator: " ").map { Int($0)! } }
    }

    /// The version's codewords: its modules less the function patterns, over 8.
    static func codewords(_ version: Int) -> Int {
        var modules = (16 * version + 128) * version + 64
        if version >= 2 {
            let align = version / 7 + 2
            modules -= (25 * align - 10) * align - 55
            if version >= 7 { modules -= 36 }
        }
        return modules >> 3
    }

    static func dataCodewords(_ version: Int, _ l: Int) -> Int {
        codewords(version) - eccPerBlock[l][version] * blocks[l][version]
    }

    /// The most bytes a version holds at a level: its data, less the mode and the count.
    static func capacity(_ version: Int, _ l: Int) -> Int {
        (dataCodewords(version, l) * 8 - 4 - (version < 10 ? 8 : 16)) / 8
    }

    /// The alignment patterns' centre coordinates: 6, then evenly spaced back from `size − 7`.
    static func alignment(_ version: Int, size: Int) -> [Int] {
        if version == 1 { return [] }
        let count = version / 7 + 2
        let step = (version * 8 + count * 3 + 5) / (count * 4 - 4) * 2
        var positions = [6]
        var at = size - 7
        while positions.count < count {
            positions.insert(at, at: 1)
            at -= step
        }
        return positions
    }

    /// The format word: the level's two bits and the mask's three, BCH(15, 5) with generator 0x537,
    /// masked with 0x5412.
    static func formatBits(_ l: Int, mask: Int) -> Int {
        let data = format[l] << 3 | mask
        var remainder = data
        for _ in 0..<10 { remainder = (remainder << 1) ^ ((remainder >> 9) * 0x537) }
        return (data << 10 | remainder) ^ 0x5412
    }

    /// The version word, BCH(18, 6) with generator 0x1F25.
    static func versionBits(_ version: Int) -> Int {
        var remainder = version
        for _ in 0..<12 { remainder = (remainder << 1) ^ ((remainder >> 11) * 0x1F25) }
        return version << 12 | remainder
    }

    /// Whether mask pattern `mask` inverts the module at column `x`, row `y`.
    static func masks(_ mask: Int, x: Int, y: Int) -> Bool {
        switch mask {
        case 0: (x + y) % 2 == 0
        case 1: y % 2 == 0
        case 2: x % 3 == 0
        case 3: (x + y) % 3 == 0
        case 4: (x / 3 + y / 2) % 2 == 0
        case 5: x * y % 2 + x * y % 3 == 0
        case 6: (x * y % 2 + x * y % 3) % 2 == 0
        default: ((x + y) % 2 + x * y % 3) % 2 == 0
        }
    }
}

/// Reed–Solomon error correction over GF(256), as the web computes it.
enum QeetrixQRCodeReedSolomon {
    /// The product in GF(256), reducing by x⁸ + x⁴ + x³ + x² + 1 (0x11D) as it goes.
    static func times(_ x: Int, _ y: Int) -> Int {
        var z = 0
        for i in stride(from: 7, through: 0, by: -1) {
            z = (z << 1) ^ ((z >> 7) * 0x11D)
            z ^= ((y >> i) & 1) * x
        }
        return z
    }

    /// The generator polynomial of `degree` (the product of (x − 2ⁱ) for i below `degree`), highest
    /// power first and its leading 1 left out.
    static func divisor(degree: Int) -> [Int] {
        var divisor = Array(repeating: 0, count: degree)
        divisor[degree - 1] = 1
        var root = 1
        for _ in 0..<degree {
            for j in 0..<degree {
                divisor[j] = times(divisor[j], root) ^ (j + 1 < degree ? divisor[j + 1] : 0)
            }
            root = times(root, 2)
        }
        return divisor
    }

    /// The `degree` error-correction codewords of a block of data codewords.
    static func remainder(_ data: [Int], degree: Int) -> [Int] {
        let divisor = divisor(degree: degree)
        var remainder = Array(repeating: 0, count: degree)
        for byte in data {
            let factor = byte ^ remainder.removeFirst()
            remainder.append(0)
            for j in 0..<degree { remainder[j] ^= times(divisor[j], factor) }
        }
        return remainder
    }
}

/// The web encoder's mask penalty (`penalty` in encode.js).
enum QeetrixQRCodePenalty {
    static let finderLike: [[UInt8]] = [[1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1]]

    static func score(_ dark: [UInt8], size: Int) -> Int {
        var score = 0
        var line = Array(repeating: UInt8(0), count: size)
        for column in [false, true] {
            for i in 0..<size {
                for j in 0..<size { line[j] = column ? dark[j * size + i] : dark[i * size + j] }
                score += runs(line) + 40 * finderLikeCount(line)
            }
        }
        for y in 0..<size - 1 {
            for x in 0..<size - 1 {
                let c = dark[y * size + x]
                if c == dark[y * size + x + 1] && c == dark[(y + 1) * size + x] && c == dark[(y + 1) * size + x + 1] { score += 3 }
            }
        }
        let total = dark.reduce(0) { $0 + Int($1) }
        return score + 10 * (abs(total * 20 - size * size * 10) / (size * size))
    }

    /// Each run of five or more modules of one colour scores its length less two (`/0{5,}|1{5,}/g`).
    static func runs(_ line: [UInt8]) -> Int {
        var score = 0
        var run = 1
        for j in 1..<line.count {
            if line[j] == line[j - 1] {
                run += 1
            } else {
                if run >= 5 { score += run - 2 }
                run = 1
            }
        }
        if run >= 5 { score += run - 2 }
        return score
    }

    /// Occurrences of either finder-like pattern inside the line, overlapping ones included
    /// (`indexOf(pattern, at + 1)`).
    static func finderLikeCount(_ line: [UInt8]) -> Int {
        guard line.count >= 11 else { return 0 }
        var count = 0
        for start in 0...(line.count - 11) {
            for pattern in finderLike where line[start..<start + 11].elementsEqual(pattern) { count += 1 }
        }
        return count
    }
}
