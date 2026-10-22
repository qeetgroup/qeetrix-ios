import Foundation

/// One icon from the pinned qeetrix-icons manifest, with its drawings.
public struct IconSpec: Equatable, Sendable {
    public let name: String
    public let componentName: String
    public let mirrors: Bool
    /// Drawings keyed by `"<shape>-<variant>"`, e.g. `round-outline`.
    public let drawings: [(key: String, drawing: IconDrawing)]

    public static func == (lhs: IconSpec, rhs: IconSpec) -> Bool {
        lhs.name == rhs.name && lhs.componentName == rhs.componentName && lhs.mirrors == rhs.mirrors
            && lhs.drawings.map(\.key) == rhs.drawings.map(\.key) && lhs.drawings.map(\.drawing) == rhs.drawings.map(\.drawing)
    }
}

public enum IconCatalog {
    public static let shapes = ["round", "sharp"]
    public static let variants = ["outline", "filled"]

    /// Reads `icons.json` (the manifest entries for the pinned icons) and every drawing they list.
    public static func load(manifest: Data, svgDirectory: URL) throws -> [IconSpec] {
        guard case let .array(entries) = try OrderedJSON.parse(manifest, context: "icons.json") else {
            throw GeneratorError("icons.json: expected an array of manifest entries.")
        }
        return try entries.map { entry in
            guard let name = entry["name"]?.stringValue, let component = entry["componentName"]?.stringValue,
                let shapes = entry["shapes"]?.arrayValue?.compactMap(\.stringValue),
                let variants = entry["variants"]?.arrayValue?.compactMap(\.stringValue),
                let directionality = entry["directionality"]?.stringValue
            else { throw GeneratorError("icons.json: an entry is missing name, componentName, shapes, variants or directionality.") }
            guard directionality == "mirror" || directionality == "preserve" else {
                throw GeneratorError("icons.json: \(name) has unknown directionality \"\(directionality)\".")
            }
            var drawings: [(key: String, drawing: IconDrawing)] = []
            for shape in Self.shapes where shapes.contains(shape) {
                for variant in Self.variants where variants.contains(variant) {
                    let key = "\(shape)-\(variant)"
                    let url = svgDirectory.appendingPathComponent(key).appendingPathComponent("\(name).svg")
                    guard let data = try? Data(contentsOf: url) else {
                        throw GeneratorError("\(name): the manifest lists \(key) but \(url.lastPathComponent) is not in the snapshot.")
                    }
                    drawings.append((key, try SVGParser.parse(data, context: "\(key)/\(name).svg")))
                }
            }
            guard drawings.contains(where: { $0.key == "round-outline" }) else {
                throw GeneratorError("\(name): every icon needs a round outline drawing (the default).")
            }
            return IconSpec(name: name, componentName: component, mirrors: directionality == "mirror", drawings: drawings)
        }
    }
}

public struct IconEmitter {
    let icons: [IconSpec]
    let provenance: Provenance

    public static let path = "Sources/Qeetrix/Icons/Generated/QeetrixIconCatalog.swift"

    public init(icons: [IconSpec], provenance: Provenance) {
        self.icons = icons
        self.provenance = provenance
    }

    static func cap(_ value: String) -> String {
        ["butt": ".butt", "round": ".round", "square": ".square"][value]!
    }

    static func join(_ value: String) -> String {
        ["miter": ".miter", "round": ".round", "bevel": ".bevel"][value]!
    }

    static func command(_ command: PathCommand) -> String {
        func list(_ values: Double...) -> String { values.map(swiftNumber).joined(separator: ", ") }
        switch command {
        case let .move(x, y): return ".move(\(list(x, y)))"
        case let .line(x, y): return ".line(\(list(x, y)))"
        case let .quad(cx, cy, x, y): return ".quad(\(list(cx, cy, x, y)))"
        case let .cubic(c1x, c1y, c2x, c2y, x, y): return ".cubic(\(list(c1x, c1y, c2x, c2y, x, y)))"
        case .close: return ".close"
        case let .ellipse(x, y, w, h): return ".ellipse(\(list(x, y, w, h)))"
        case let .roundedRect(x, y, w, h, rx, ry): return ".roundedRect(\(list(x, y, w, h, rx, ry)))"
        }
    }

    public func file() throws -> GeneratedFile {
        let names = try icons.map { try SwiftNames.identifier([$0.name], context: "icon \($0.name)") }
        try SwiftNames.requireUnique(Array(zip(names, icons.map(\.name))), scope: "QeetrixIconName")

        var members: [String] = []
        var tableEntries: [String] = []
        var drawings: [String] = []
        for (name, icon) in zip(names, icons) {
            let keys = icon.drawings.map(\.key).joined(separator: ", ")
            members.append(
                "    /// `\(icon.name)` — `\(icon.componentName)` in \(provenance.iconsPackage). Drawings: \(keys).\(icon.mirrors ? " Mirrors in right-to-left layouts." : "")\n    public static let \(SwiftNames.declaration(name)) = QeetrixIconName(\(swiftString(icon.name)))\n"
            )
            for (key, drawing) in icon.drawings {
                let parts = key.split(separator: "-").map(String.init)
                let constant = try SwiftNames.identifier([icon.name] + parts, context: "\(icon.name) \(key)")
                tableEntries.append(
                    "        QeetrixIconDrawingKey(name: .\(name), shape: .\(parts[0]), variant: .\(parts[1])): QeetrixIconDrawings.\(constant),\n"
                )
                var elements = ""
                for element in drawing.elements {
                    let fill = element.fill ? (element.evenOdd ? ".evenOdd" : ".nonZero") : "nil"
                    let stroke =
                        element.stroke
                        ? "QeetrixIconStrokeStyle(cap: \(Self.cap(element.lineCap)), join: \(Self.join(element.lineJoin)))" : "nil"
                    elements +=
                        "            QeetrixIconElement(\n                fill: \(fill), stroke: \(stroke),\n                commands: [\n"
                    elements += element.commands.map { "                    \(Self.command($0)),\n" }.joined()
                    elements += "                ]),\n"
                }
                drawings.append(
                    "    /// `icons/\(key)/…/\(icon.name).svg`\n    static let \(constant) = QeetrixIconDrawing(\n        miterLimit: \(swiftNumber(drawing.miterLimit)),\n        elements: [\n\(elements)        ])\n"
                )
            }
        }
        let mirrored = zip(names, icons).filter { $0.1.mirrors }.map { ".\($0.0)" }
        let allCases = names.map { "        .\($0),\n" }.joined()

        return GeneratedFile(
            path: Self.path,
            contents: """
                // GENERATED by qeetrix-gen from \(provenance.iconsRepository)@\(provenance.iconsCommit.prefix(7)) (\(provenance.iconsPackage) \(provenance.iconsVersion)) — do not edit.
                // Add an icon to Upstream/pins.json, run Scripts/sync-upstream.sh, then Scripts/generate.sh.

                import CoreGraphics

                /// The Qeetrix icons available natively. Names are qeetrix-icons' (Lucide's) names; raw values
                /// are the exact upstream names. The catalogue carries a representative set, and grows.
                ///
                /// An open set of names, like `Notification.Name`, rather than an enum: adding an icon is an
                /// addition, not a source-breaking change for code that switches over icons (ADR 0016). Switch
                /// with a `default` case; `allCases` lists the catalogue.
                public struct QeetrixIconName: RawRepresentable, Hashable, CaseIterable, Sendable {
                    /// The upstream name, such as `chevron-down`.
                    public let rawValue: String

                    /// The icon named `rawValue` in the catalogue, or `nil` for a name it doesn't have.
                    public init?(rawValue: String) {
                        guard Self.allCases.contains(where: { $0.rawValue == rawValue }) else { return nil }
                        self.rawValue = rawValue
                    }

                    private init(_ rawValue: String) {
                        self.rawValue = rawValue
                    }

                \(members.joined(separator: "\n"))
                    /// Every icon in the catalogue, in name order.
                    public static let allCases: [QeetrixIconName] = [
                \(allCases)    ]

                    /// The icons whose drawing mirrors in right-to-left layouts (`directionality: "mirror"` upstream).
                    static let mirrored: Set<QeetrixIconName> = [\(mirrored.joined(separator: ", "))]

                    /// Whether the drawing mirrors in right-to-left layouts (`directionality: "mirror"` upstream).
                    public var mirrorsInRightToLeft: Bool {
                        Self.mirrored.contains(self)
                    }
                }

                extension QeetrixIconName {
                    /// The drawing for a shape and variant, or `nil` when qeetrix-icons does not draw that combination.
                    func drawing(_ shape: QeetrixIconShape, _ variant: QeetrixIconVariant) -> QeetrixIconDrawing? {
                        QeetrixIconDrawings.table[QeetrixIconDrawingKey(name: self, shape: shape, variant: variant)]
                    }
                }

                struct QeetrixIconDrawingKey: Hashable, Sendable {
                    let name: QeetrixIconName
                    let shape: QeetrixIconShape
                    let variant: QeetrixIconVariant
                }

                /// Path data in the 24-unit grid, converted from the pinned SVGs: arcs and smooth curves are
                /// already expanded to cubic Béziers.
                enum QeetrixIconDrawings {
                    /// Every drawing, by icon, shape and variant.
                    static let table: [QeetrixIconDrawingKey: QeetrixIconDrawing] = [
                \(tableEntries.joined())    ]

                \(drawings.joined(separator: "\n"))}

                """)
    }
}
