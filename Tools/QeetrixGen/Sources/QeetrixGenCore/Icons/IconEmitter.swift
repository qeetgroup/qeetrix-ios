import Foundation

/// One icon from the pinned `@qeetrix/icons` manifest, with its drawings.
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

    /// Reads `icons.json` (the manifest entries for the pinned icons) and every drawing they list from
    /// `svg/<shape>-<variant>/<name>.svg`, the SVG files `@qeetrix/icons` publishes, validated and
    /// converted by the SVG parser.
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
            for shape in Self.shapes {
                for variant in Self.variants {
                    let key = "\(shape)-\(variant)"
                    let file = "svg/\(key)/\(name).svg"
                    let data = try? Data(contentsOf: svgDirectory.appendingPathComponent("\(key)/\(name).svg"))
                    switch (shapes.contains(shape) && variants.contains(variant), data) {
                    case let (true, data?): drawings.append((key, try SVGParser.parse(data, context: file)))
                    case (true, nil): throw GeneratorError("\(name): the manifest lists \(key) but \(file) is not in the snapshot.")
                    case (false, _?): throw GeneratorError("\(name): \(file) is in the snapshot, but the manifest does not list \(key).")
                    case (false, nil): continue
                    }
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
    let core: [IconSpec]
    let extended: [IconSpec]
    let provenance: Provenance

    public static let path = "Sources/Qeetrix/Icons/Generated/QeetrixIconCatalog.swift"
    public static let extendedDirectory = "Sources/QeetrixIconsExtended/Generated"

    /// `core`: the pinned icons, in `QeetrixIconName` itself. `extended`: every other icon, in the optional
    /// `QeetrixIconsExtended` product.
    public init(core: [IconSpec], extended: [IconSpec], provenance: Provenance) {
        self.core = core
        self.extended = extended
        self.provenance = provenance
    }

    /// A drawing as one string, decoded by `QeetrixIconName` (Sources/Qeetrix/Icons/QeetrixIconDrawing.swift): the miter
    /// limit, then each element after a `|` — four flags (fill `-`/`n`onzero/`e`ven-odd, stroke `-`/`s`, cap
    /// `b`utt/`r`ound/`s`quare, join `m`iter/`r`ound/`b`evel) and its absolute commands, `M x y`, `L x y`,
    /// `Q cx cy x y`, `C c1x c1y c2x c2y x y`, `Z`, and the native shapes `E x y w h` (ellipse) and
    /// `R x y w h rx ry` (rounded rectangle), numbers as the rest of the generator writes them.
    public static func encode(_ drawing: IconDrawing) -> String {
        var out = swiftNumber(drawing.miterLimit)
        func numbers(_ values: Double...) -> String { values.map(swiftNumber).joined(separator: " ") }
        for element in drawing.elements {
            out += "|"
            out += element.fill ? (element.evenOdd ? "e" : "n") : "-"
            out += element.stroke ? "s" : "-"
            out += String(element.lineCap.prefix(1))
            out += String(element.lineJoin.prefix(1))
            for command in element.commands {
                switch command {
                case let .move(x, y): out += "M" + numbers(x, y)
                case let .line(x, y): out += "L" + numbers(x, y)
                case let .quad(cx, cy, x, y): out += "Q" + numbers(cx, cy, x, y)
                case let .cubic(c1x, c1y, c2x, c2y, x, y): out += "C" + numbers(c1x, c1y, c2x, c2y, x, y)
                case .close: out += "Z"
                case let .ellipse(x, y, w, h): out += "E" + numbers(x, y, w, h)
                case let .roundedRect(x, y, w, h, rx, ry): out += "R" + numbers(x, y, w, h, rx, ry)
                }
            }
        }
        return out
    }

    static func validate(_ icon: IconSpec) throws {
        for element in icon.drawings.flatMap(\.drawing.elements) {
            guard ["butt", "round", "square"].contains(element.lineCap), ["miter", "round", "bevel"].contains(element.lineJoin)
            else { throw GeneratorError("\(icon.name): line cap \(element.lineCap) / join \(element.lineJoin) has no encoding.") }
        }
    }

    /// A core icon is a stored `static let`. An extended one is a computed property emitted into the client: Swift keeps
    /// every public symbol a library defines (they are marked no-dead-strip), so an icon the library itself compiled
    /// would ship in every app; one compiled only where an app names it ships only in that app.
    func declaration(_ icon: IconSpec, name: String, package: String, extended: Bool) -> String {
        func drawing(_ key: String) -> String {
            icon.drawings.first { $0.key == key }.map { swiftString(Self.encode($0.drawing)) } ?? "nil"
        }
        let keys = icon.drawings.map(\.key).joined(separator: ", ")
        let mirrors = icon.mirrors ? " Mirrors in right-to-left layouts." : ""
        let doc = "    /// `\(icon.name)` — `\(icon.componentName)` in \(package). Drawings: \(keys).\(mirrors)"
        let arguments = """
            \(swiftString(icon.name)), mirrors: \(icon.mirrors),
                roundOutline: \(drawing("round-outline")),
                roundFilled: \(drawing("round-filled")),
                sharpOutline: \(drawing("sharp-outline")),
                sharpFilled: \(drawing("sharp-filled")))
            """
        if extended {
            return """
                \(doc)
                    @_alwaysEmitIntoClient
                    public static var \(SwiftNames.declaration(name)): QeetrixIconName {
                        QeetrixIconName(
                            \(arguments.replacingOccurrences(of: "\n", with: "\n        "))
                    }

                """
        }
        return """
            \(doc)
                public static let \(SwiftNames.declaration(name)) = QeetrixIconName(
                    \(arguments.replacingOccurrences(of: "\n", with: "\n    "))

            """
    }

    public func files() throws -> [GeneratedFile] {
        let package = try provenance.package(Provenance.iconsPackage)
        for icon in core + extended { try Self.validate(icon) }
        let coreNames = try core.map { try SwiftNames.identifier([$0.name], context: "icon \($0.name)") }
        let extendedNames = try extended.map { try SwiftNames.identifier([$0.name], context: "icon \($0.name)") }
        try SwiftNames.requireUnique(Array(zip(coreNames + extendedNames, (core + extended).map(\.name))), scope: "QeetrixIconName")

        let members = zip(coreNames, core).map { declaration($0.1, name: $0.0, package: package.name, extended: false) }
        let allCases = coreNames.map { "        .\($0),\n" }.joined()
        var files = [
            GeneratedFile(
                path: Self.path,
                contents: """
                    // GENERATED by qeetrix-gen from \(package.name) \(package.version) — do not edit.
                    // Pin an icon in Upstream/pins.json, run Scripts/sync-upstream.sh, then Scripts/generate.sh.

                    /// A Qeetrix icon: one of `@qeetrix/icons`' icons, by its upstream (Lucide) name. Raw values are the
                    /// exact upstream names.
                    ///
                    /// - The **core icons** — the ones the components and the showcase draw — are here: `.send`.
                    /// - **Every other icon** is in the optional `QeetrixIconsExtended` product, by the same kind of name:
                    ///   `.alarmClock`, after `import QeetrixIconsExtended`. An app links only the icons it names.
                    ///
                    /// An open set of names, like `Notification.Name`, rather than an enum: adding an icon is an
                    /// addition, not a source-breaking change for code that switches over icons (ADR 0016). Switch
                    /// with a `default` case; `allCases` lists the core catalogue. Two names are equal when their raw
                    /// values are.
                    public struct QeetrixIconName: RawRepresentable, Hashable, CaseIterable, Sendable {
                        /// The upstream name, such as `chevron-down`.
                        public let rawValue: String

                        /// Whether the drawing mirrors in right-to-left layouts (`directionality: "mirror"` upstream).
                        public let mirrorsInRightToLeft: Bool

                        // The drawings, encoded by the generator; decoded the first time each is drawn.
                        let roundOutline: String?
                        let roundFilled: String?
                        let sharpOutline: String?
                        let sharpFilled: String?

                        /// The core icon named `rawValue`, or `nil` for a name the core catalogue doesn't have.
                        public init?(rawValue: String) {
                            guard let icon = Self.allCases.first(where: { $0.rawValue == rawValue }) else { return nil }
                            self = icon
                        }

                        /// An icon from the generator's encoded drawings: for Qeetrix's generated catalogues only.
                        /// `@usableFromInline` because the extended icons are emitted into the apps that name them.
                        @usableFromInline
                        package init(
                            _ rawValue: String, mirrors: Bool, roundOutline: String?, roundFilled: String?, sharpOutline: String?,
                            sharpFilled: String?
                        ) {
                            self.rawValue = rawValue
                            self.mirrorsInRightToLeft = mirrors
                            self.roundOutline = roundOutline
                            self.roundFilled = roundFilled
                            self.sharpOutline = sharpOutline
                            self.sharpFilled = sharpFilled
                        }

                        public static func == (lhs: QeetrixIconName, rhs: QeetrixIconName) -> Bool {
                            lhs.rawValue == rhs.rawValue
                        }

                        public func hash(into hasher: inout Hasher) {
                            hasher.combine(rawValue)
                        }

                    \(members.joined(separator: "\n"))
                        /// Every core icon, in name order. `QeetrixIconsExtended` lists the rest in `extendedCases`.
                        public static let allCases: [QeetrixIconName] = [
                    \(allCases)    ]
                    }

                    """)
        ]
        guard !extended.isEmpty else { return files }
        // One file per first letter: the compiler works on them in parallel.
        let groups = Dictionary(grouping: zip(extendedNames, extended).map { $0 }) { String($0.1.name.prefix(1)).uppercased() }
        for letter in groups.keys.sorted() {
            let declarations = groups[letter]!.map { declaration($0.1, name: $0.0, package: package.name, extended: true) }
            files.append(
                GeneratedFile(
                    path: "\(Self.extendedDirectory)/QeetrixIconName+\(letter).swift",
                    contents: """
                        // GENERATED by qeetrix-gen from \(package.name) \(package.version) — do not edit.

                        import Qeetrix

                        extension QeetrixIconName {
                        \(declarations.joined(separator: "\n"))}

                        """))
        }
        files.append(
            GeneratedFile(
                path: "\(Self.extendedDirectory)/ExtendedCases.swift",
                contents: """
                    // GENERATED by qeetrix-gen from \(package.name) \(package.version) — do not edit.

                    import Qeetrix

                    extension QeetrixIconName {
                        /// Every icon this product adds (\(extended.count)), in name order — for an icon picker or a gallery.
                        /// Naming it compiles every one of their drawings into the app, so an app that draws fixed icons
                        /// names them instead.
                        @_alwaysEmitIntoClient
                        public static var extendedCases: [QeetrixIconName] {
                            [
                    \(extendedNames.map { "            .\($0),\n" }.joined())        ]
                        }
                    }

                    """))
        return files
    }
}
