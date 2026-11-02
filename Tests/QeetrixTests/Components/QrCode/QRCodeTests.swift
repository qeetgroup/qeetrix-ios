import SwiftUI
import Testing

@testable import Qeetrix

#if canImport(CoreImage)
    import CoreImage
#endif

@MainActor
@Suite("QR code")
struct QRCodeTests {
    @Test("Levels are the web's L, M, Q and H, each holding the standard's bytes in versions 1 and 40")
    func levels() {
        #expect(QeetrixQRCodeLevel.allCases.map(\.rawValue) == ["L", "M", "Q", "H"])
        #expect(QeetrixQRCodeLevel.allCases.map(\.maximumByteCount) == [2953, 2331, 1663, 1273])
        #expect(QeetrixQRCodeLevel.allCases.map { QeetrixQRCodeTables.capacity(1, $0.index) } == [17, 14, 11, 7])
    }

    @Test("Each reference value gives the web encoder's version, mask penalties, mask and modules", arguments: QRCodeReference.all)
    func matchesTheWeb(_ reference: QRCodeReference) throws {
        let matrix = try QeetrixQRCodeMatrix(reference.value, level: reference.level)
        #expect(matrix.version == reference.version)
        #expect(matrix.size == reference.version * 4 + 17)
        #expect(matrix.penalties == reference.penalties)
        #expect(matrix.mask == reference.mask)
        let rows = (0..<matrix.size).map { y in String((0..<matrix.size).map { matrix[$0, y] ? "#" : "." }) }
        #expect(rows == reference.rows.split(separator: "\n").map(String.init))
    }

    @Test("The value is encoded as UTF-8 bytes: the mode, the count, the bytes, a terminator and pad bytes")
    func dataCodewords() {
        // "01234567" at 1-M, worked by hand: 0100, 00001000, then 0x30…0x37, 0000, then 236 and 17.
        let stream = QeetrixQRCodeMatrix.codewords(Array("01234567".utf8), version: 1, l: QeetrixQRCodeLevel.m.index)
        #expect(stream.count == 26)
        #expect(Array(stream.prefix(16)) == [0x40, 0x83, 0x03, 0x13, 0x23, 0x33, 0x43, 0x53, 0x63, 0x70, 236, 17, 236, 17, 236, 17])
        #expect(Array("₹1,250 · कीत".utf8).count == 21)
    }

    @Test("Reed–Solomon gives ISO/IEC 18004's worked example its error-correction codewords (Annex I)")
    func reedSolomon() {
        // "01234567" at 1-M in numeric mode: its 16 data codewords, and the 10 the standard lists after them.
        let annexData = [
            0b0001_0000, 0b0010_0000, 0b0000_1100, 0b0101_0110, 0b0110_0001, 0b1000_0000, 0b1110_1100, 0b0001_0001,
            0b1110_1100, 0b0001_0001, 0b1110_1100, 0b0001_0001, 0b1110_1100, 0b0001_0001, 0b1110_1100, 0b0001_0001,
        ]
        let annexCorrection = [
            0b1010_0101, 0b0010_0100, 0b1101_0100, 0b1100_0001, 0b1110_1101, 0b0011_0110, 0b1100_0111, 0b1000_0111, 0b0010_1100,
            0b0101_0101,
        ]
        #expect(QeetrixQRCodeReedSolomon.remainder(annexData, degree: 10) == annexCorrection)
        // "HELLO WORLD" at 1-M in alphanumeric mode, the example most tutorials work through.
        #expect(
            QeetrixQRCodeReedSolomon.remainder([32, 91, 11, 120, 209, 114, 220, 77, 67, 64, 236, 17, 236, 17, 236, 17], degree: 10)
                == [196, 35, 39, 119, 235, 215, 231, 226, 93, 23])
        #expect(QeetrixQRCodeReedSolomon.times(0x80, 2) == 0x1D, "x⁸ reduces by x⁸ + x⁴ + x³ + x² + 1")
    }

    @Test("Format and version words are the standard's BCH codes")
    func bch() {
        let l = QeetrixQRCodeLevel.l.index
        let m = QeetrixQRCodeLevel.m.index
        let q = QeetrixQRCodeLevel.q.index
        let h = QeetrixQRCodeLevel.h.index
        #expect(QeetrixQRCodeTables.formatBits(l, mask: 0) == 0b111_0111_1100_0100)
        #expect(QeetrixQRCodeTables.formatBits(l, mask: 4) == 0b110_0110_0010_1111)
        #expect(QeetrixQRCodeTables.formatBits(m, mask: 0) == 0b101_0100_0001_0010)
        #expect(QeetrixQRCodeTables.formatBits(m, mask: 5) == 0b100_0000_1100_1110)
        #expect(QeetrixQRCodeTables.formatBits(q, mask: 6) == 0b010_1110_1101_1010)
        #expect(QeetrixQRCodeTables.formatBits(h, mask: 7) == 0b000_1000_0011_1011)
        let words = Set((0..<4).flatMap { level in (0..<8).map { QeetrixQRCodeTables.formatBits(level, mask: $0) } })
        #expect(words.count == 32 && words.allSatisfy { $0 >> 15 == 0 })
        #expect(QeetrixQRCodeTables.versionBits(7) == 0b00_0111_1100_1001_0100)
        #expect(QeetrixQRCodeTables.versionBits(8) == 0b00_1000_0101_1011_1100)
        #expect(QeetrixQRCodeTables.versionBits(40) == 0b10_1000_1100_0110_1001)
    }

    @Test("Alignment pattern centres follow the standard's table, version 32's uneven step included")
    func alignment() {
        #expect(QeetrixQRCodeTables.alignment(1, size: 21).isEmpty)
        #expect(QeetrixQRCodeTables.alignment(2, size: 25) == [6, 18])
        #expect(QeetrixQRCodeTables.alignment(7, size: 45) == [6, 22, 38])
        #expect(QeetrixQRCodeTables.alignment(32, size: 145) == [6, 34, 60, 86, 112, 138])
        #expect(QeetrixQRCodeTables.alignment(40, size: 177) == [6, 30, 58, 86, 114, 142, 170])
    }

    @Test("The smallest version that holds the value; past version 40 there is no code")
    func versions() throws {
        #expect(try QeetrixQRCodeMatrix(String(repeating: "a", count: 14), level: .m).version == 1)
        #expect(try QeetrixQRCodeMatrix(String(repeating: "a", count: 15), level: .m).version == 2)
        #expect(try QeetrixQRCodeMatrix(String(repeating: "a", count: 2953), level: .l).version == 40)
        #expect(throws: QeetrixQRCodeTooLong(byteCount: 2954, level: .l)) {
            try QeetrixQRCodeMatrix(String(repeating: "a", count: 2954), level: .l)
        }
        #expect(throws: QeetrixQRCodeTooLong(byteCount: 1274, level: .h)) {
            try QeetrixQRCodeMatrix(String(repeating: "a", count: 1274), level: .h)
        }
        #expect(QeetrixQRCodeCache().matrix(String(repeating: "a", count: 2954), level: .l) == nil)
        #expect(QeetrixQRCodeCache().matrix("Qeetrix", level: .m)?.mask == QRCodeReference.qeetrixM.mask)
    }

    @Test("Dark on white in both schemes, the quiet zone inside the tile, and never mirrored")
    func drawing() throws {
        // Version 1 is 21 modules, 29 with the quiet zone: at 116 pt a module is 4 pixels.
        let tile = QeetrixQRCodeTile(value: "Qeetrix", level: .m, side: 116)
        var images: [Rendered] = []
        for scheme in [ColorScheme.light, .dark] {
            let image = try #require(Rendered(tile.environment(\.colorScheme, scheme)))
            #expect(image.width == 116 && image.height == 116)
            let white = QeetrixTheme.light.resolve(.surfaceDefault).bytes
            let ink = QeetrixTheme.light.resolve(.textDefault).bytes
            #expect(white == (255, 255, 255))
            #expect(close(white, image.pixel(10, 58)), "The quiet zone, in \(scheme)")
            #expect(close(ink, image.pixel(16 + 3 * 4 + 2, 16 + 3 * 4 + 2)), "The top-left finder's centre, in \(scheme)")
            #expect(close(white, image.pixel(16 + 1 * 4 + 2, 16 + 1 * 4 + 2)), "The finder's light ring, in \(scheme)")
            #expect(close(QeetrixTheme.light.resolve(.borderSubtle).bytes, image.pixel(58, 0)), "The hairline tile, in \(scheme)")
            images.append(image)
        }
        let rightToLeft = try #require(Rendered(tile.environment(\.layoutDirection, .rightToLeft)))
        // Only the left-hand finders are at the bottom: (3, 17) is a finder's centre, (17, 17) is not.
        #expect(close(QeetrixTheme.light.resolve(.textDefault).bytes, rightToLeft.pixel(16 + 3 * 4 + 2, 16 + 17 * 4 + 2)))
        for (x, y) in [(18, 18), (58, 58), (90, 30), (30, 90), (98, 98)] {
            #expect(images[0].pixel(x, y) == rightToLeft.pixel(x, y))
        }
    }

    #if canImport(CoreImage)
        @Test(
            "What it draws scans back to its value, in both schemes",
            arguments: [QRCodeReference.qeetrixM, .otpauthQ, .upiH, .rupeeHindiQ])
        func scans(_ reference: QRCodeReference) throws {
            for scheme in [ColorScheme.light, .dark] {
                let renderer = ImageRenderer(
                    content: QeetrixQRCode(reference.value, label: "Test code", level: reference.level, size: 320)
                        .environment(\.colorScheme, scheme))
                renderer.scale = 2
                let image = try #require(renderer.cgImage)
                let detector = try #require(
                    CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]))
                let decoded = detector.features(in: CIImage(cgImage: image)).compactMap { ($0 as? CIQRCodeFeature)?.messageString }
                #expect(decoded == [reference.value], "\(scheme)")
            }
        }
    #endif

    @Test("It renders, with and without its text, and as an empty tile for too long a value")
    func renders() {
        #expect(ImageRenderer(content: QeetrixQRCode("https://qeet.in", label: "QR code to open qeet.in")).cgImage != nil)
        #expect(
            ImageRenderer(content: QeetrixQRCode(QRCodeReference.otpauth, label: Text("Add Qeet ID"), text: Text("JBSW Y3DP EHPK 3PXP")))
                .cgImage != nil)
        #expect(
            ImageRenderer(content: QeetrixQRCode(String(repeating: "a", count: 1300), label: "Too long", level: .h)).cgImage != nil)
    }
}

extension QRCodeReference: CustomTestStringConvertible {
    var testDescription: String { "\(level.rawValue) v\(version) \(value.prefix(24).debugDescription)" }
}
