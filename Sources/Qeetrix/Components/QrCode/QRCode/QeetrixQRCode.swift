import SwiftUI
import os

/// How much of a QR code can be lost and still read, as `@qeetrix/react`'s `QRCodeLevel`. A higher
/// level survives more damage and needs more modules for the same value.
public enum QeetrixQRCodeLevel: String, CaseIterable, Sendable {
    /// 7% can be lost.
    case l = "L"
    /// 15%, the default.
    case m = "M"
    /// 25%.
    case q = "Q"
    /// 30%.
    case h = "H"

    /// The most UTF-8 bytes a code holds at this level, in its largest version (40): 2,953 at `l`,
    /// 2,331 at `m`, 1,663 at `q` and 1,273 at `h`. Check a value against it before showing it: a
    /// longer one draws an empty tile, where the web throws a `RangeError`.
    public var maximumByteCount: Int {
        QeetrixQRCodeTables.capacity(40, index)
    }

    var index: Int {
        switch self {
        case .l: 0
        case .m: 1
        case .q: 2
        case .h: 3
        }
    }
}

/// Text a phone camera can read — an `otpauth://` link to add an account to an authenticator, a UPI
/// payment link — as `@qeetrix/react`'s QRCode: the same modules as the web's for the same value and
/// level, always dark on white, with the standard's four-module quiet zone inside the tile.
///
/// ```swift
/// QeetrixQRCode(setupLink, label: "QR code to add Acme to your authenticator app", text: Text(setupKey))
/// QeetrixQRCode(upiLink, label: "QR code to pay Acme Traders by UPI", level: .q, text: Text("acme@upi"))
/// ```
///
/// - **Encoding:** Qeetrix's own encoder, the web's line for line: the value as UTF-8 in byte mode, the
///   smallest of versions 1 to 40 that holds it at `level`, the mask the web would choose. A value longer
///   than ``QeetrixQRCodeLevel/maximumByteCount`` draws an empty tile and logs an error.
/// - **Drawing:** `size` points square, the quiet zone included, in whole modules with crisp edges:
///   `color.text.default` on `color.surface.default` inside a hairline `color.border.subtle` tile with
///   `radius.control` corners, all in the light scheme whatever the colour scheme, and left as it is by
///   Smart Invert — a camera needs the dark-on-light contrast either way.
/// - **`text`:** the same thing as text, for anyone who can't scan: the setup key, the UPI ID. It is
///   shown under the tile in `code.md`, and can be selected and copied. On the web this text belongs to
///   the product; give it here, or show it yourself.
///
/// VoiceOver reads `label` — what the code is for — as an image, then `text`. The value is never
/// logged; for a code that holds a secret, mark the view `privacySensitive()`.
public struct QeetrixQRCode: View {
    let value: String
    let label: Text
    let level: QeetrixQRCodeLevel
    let size: CGFloat
    let text: Text?

    /// A QR code with a localised accessible label.
    public init(_ value: String, label: LocalizedStringKey, level: QeetrixQRCodeLevel = .m, size: CGFloat = 160, text: Text? = nil) {
        self.init(value, label: Text(label), level: level, size: size, text: text)
    }

    /// A QR code with an accessible label used as given, without localisation.
    public init<S: StringProtocol>(_ value: String, label: S, level: QeetrixQRCodeLevel = .m, size: CGFloat = 160, text: Text? = nil) {
        self.init(value, label: Text(label), level: level, size: size, text: text)
    }

    /// A QR code with a `Text` accessible label.
    public init(_ value: String, label: Text, level: QeetrixQRCodeLevel = .m, size: CGFloat = 160, text: Text? = nil) {
        self.value = value
        self.label = label
        self.level = level
        self.size = size
        self.text = text
    }

    public var body: some View {
        VStack(spacing: QeetrixSpace.gapSm) {
            QeetrixQRCodeTile(value: value, level: level, side: size)
                .accessibilityElement()
                .accessibilityLabel(label)
                .accessibilityAddTraits(.isImage)
            if let text {
                text
                    .qeetrixTextStyle(.codeMd)
                    .foregroundStyle(QeetrixColor.textDefault)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }
        }
    }
}

/// The tile: the modules in a `viewBox` four modules wider on every side (`-4 -4 (n + 8) (n + 8)`),
/// each edge on a device pixel and filled without anti-aliasing (`shape-rendering: crispEdges`), so
/// neighbouring modules meet without seams.
struct QeetrixQRCodeTile: View {
    let value: String
    let level: QeetrixQRCodeLevel
    let side: CGFloat
    @State private var cache = QeetrixQRCodeCache()
    @Environment(\.displayScale) private var displayScale

    /// The quiet zone, in modules: the standard's four, inside the tile.
    static let quietZone = 4

    var body: some View {
        let matrix = cache.matrix(value, level: level)
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        let scale = displayScale
        Canvas { context, size in
            guard let matrix else { return }
            context.fill(
                Self.path(matrix, side: size.width, scale: scale), with: .style(QeetrixColor.textDefault),
                style: FillStyle(antialiased: false))
        }
        .frame(width: side, height: side)
        .background(QeetrixColor.surfaceDefault, in: shape)
        // qr-code.css: `box-shadow: inset 0 0 0 var(--qx-border-width-default) var(--qx-color-border-subtle)`.
        .overlay { shape.strokeBorder(QeetrixColor.borderSubtle, lineWidth: QeetrixBorderWidth.default) }
        // `color-scheme: light` and `data-qx-color-scheme="light"`: white and the light scheme's text.
        .environment(\.colorScheme, .light)
        // `forced-color-adjust: none`.
        .accessibilityIgnoresInvertColors()
    }

    /// One rectangle per horizontal run of dark modules, as the web's path is drawn, with each edge
    /// rounded to the nearest device pixel.
    static func path(_ matrix: QeetrixQRCodeMatrix, side: CGFloat, scale: CGFloat) -> Path {
        let module = side / CGFloat(matrix.size + 2 * quietZone)
        let pixel = max(scale, 1)
        func edge(_ index: Int) -> CGFloat {
            (CGFloat(index + quietZone) * module * pixel).rounded() / pixel
        }
        var path = Path()
        for y in 0..<matrix.size {
            var x = 0
            while x < matrix.size {
                guard matrix[x, y] else {
                    x += 1
                    continue
                }
                let start = x
                while x + 1 < matrix.size && matrix[x + 1, y] { x += 1 }
                path.addRect(CGRect(x: edge(start), y: edge(y), width: edge(x + 1) - edge(start), height: edge(y + 1) - edge(y)))
                x += 1
            }
        }
        return path
    }
}

/// The last value's modules, so a view redrawn many times a second (in a `TimelineView`, say) encodes
/// its value once.
@MainActor
final class QeetrixQRCodeCache {
    private var value: String?
    private var level: QeetrixQRCodeLevel?
    private var matrix: QeetrixQRCodeMatrix?

    static let log = Logger(subsystem: "in.qeet.qeetrix", category: "qr-code")

    func matrix(_ value: String, level: QeetrixQRCodeLevel) -> QeetrixQRCodeMatrix? {
        if value == self.value && level == self.level { return matrix }
        do {
            matrix = try QeetrixQRCodeMatrix(value, level: level)
        } catch {
            // The byte count only: a QR code's value can be a secret.
            Self.log.error(
                "A QR code value of \(error.byteCount, privacy: .public) bytes is longer than level \(level.rawValue, privacy: .public) holds (\(level.maximumByteCount, privacy: .public)); its tile is empty."
            )
            matrix = nil
        }
        self.value = value
        self.level = level
        return matrix
    }
}
