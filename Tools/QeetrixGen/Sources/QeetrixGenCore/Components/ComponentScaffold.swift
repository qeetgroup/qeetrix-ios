import Foundation

/// `qeetrix-gen new-component`: the file set every component starts from (Documentation/Standards/
/// COMPONENT_CONTRACT.md), rendered from `Templates/Component/`.
///
/// It plans every change before making any, so a run either does everything or nothing. It never
/// overwrites: a component that already exists — any of its files, its DocC topic or its showcase
/// entry — stops the run with the reasons, and running it twice changes nothing the second time. Output
/// depends only on the request and the repository's files, so the same request gives the same bytes.
public struct ComponentScaffold {
    public let root: URL

    public init(root: URL) {
        self.root = root
    }

    /// What to scaffold.
    public struct Request: Equatable, Sendable {
        /// The `@qeetrix/react` family, in UpperCamelCase: `Button` for the `button` family.
        public var family: String
        /// The iOS component name without the `Qeetrix` prefix, e.g. `IconButton`.
        public var component: String
        /// The web part the component implements, when its name differs from the component's, e.g.
        /// `TextField`; defaults to the component name.
        public var slug: String?
        /// The ui.qeet.in documentation category, e.g. `Actions`.
        public var category: String

        public init(family: String, component: String, slug: String? = nil, category: String) {
            self.family = family
            self.component = component
            self.slug = slug
            self.category = category
        }
    }

    /// A planned change: a new file, or the new contents of an existing one.
    public struct Change: Equatable, Sendable {
        public enum Kind: String, Sendable {
            case create
            case update
        }

        public let kind: Kind
        public let path: String
        public let contents: String
    }

    /// The documentation categories of ui.qeet.in, with the showcase's case name for each.
    public static let categories: [(name: String, showcaseCase: String)] = [
        ("Actions", "actions"), ("Forms & inputs", "forms"), ("Date & time", "dateTime"), ("Data display", "dataDisplay"),
        ("Feedback", "feedback"), ("Overlays", "overlays"), ("Navigation", "navigation"), ("Layout", "layout"),
        ("Utilities", "utilities"),
    ]

    /// `@qeetrix/react`'s component manifest (`dist/manifest.json`), as the sync keeps it.
    static let manifestPath = "Upstream/qeetrix-react/component-manifest.json"
    static let tokensPath = "Upstream/qeetrix-tokens/dtcg/light.tokens.json"
    static let landingPath = "Sources/Qeetrix/Qeetrix.docc/Qeetrix.md"
    static let catalogPath = "Examples/QeetrixShowcase/QeetrixShowcase/Support/ShowcaseCatalog.swift"
    static let catalogMarker = "        // new-component: insert above this line"
    static let templates: [(template: String, destination: String)] = [
        ("Component.swift.template", "Sources/Qeetrix/Components/{{Family}}/{{Component}}/Qeetrix{{Component}}.swift"),
        ("ComponentTests.swift.template", "Tests/QeetrixTests/Components/{{Family}}/{{Component}}Tests.swift"),
        ("ComponentSnapshotTests.swift.template", "Tests/QeetrixSnapshotTests/{{Family}}/{{Component}}SnapshotTests.swift"),
        ("Component.md.template", "Sources/Qeetrix/Qeetrix.docc/Components/{{Component}}.md"),
        ("ComponentPage.swift.template", "Examples/QeetrixShowcase/QeetrixShowcase/Components/{{Family}}/{{Component}}Page.swift"),
    ]

    /// Validates the request and works out every change, without touching the disk.
    public func plan(_ request: Request) throws -> [Change] {
        try Self.validateName(request.family, what: "family")
        try Self.validateName(request.component, what: "component")
        guard let category = Self.categories.first(where: { $0.name == request.category }) else {
            throw GeneratorError(
                "Unknown category \"\(request.category)\". Use one of: \(Self.categories.map(\.name).joined(separator: ", ")).")
        }
        let part = request.slug ?? request.component
        let entry = try manifestEntry(part: part)
        let slug = Self.kebab(part)  // the page on ui.qeet.in: /components/<slug>
        guard Self.upperCamel(entry.name) == request.family else {
            throw GeneratorError(
                "\(part) belongs to the \(Self.upperCamel(entry.name)) family (`\(entry.name)`) in \(Self.manifestPath), not \(request.family). Components live under their web family (ADR 0007)."
            )
        }

        let tokenGroup = try componentTokenGroup(slug: entry.name, family: request.family)
        let values: [String: String] = [
            "Family": request.family,
            "Component": request.component,
            "slug": slug,
            "title": Self.title(request.component),
            "name": part,
            "description": entry.description,
            "category": category.name,
            "pageID": Self.kebab(request.component),
            "tokens": tokenGroup.map { "component.\($0).* in @qeetrix/tokens — add a rule to Scope.swift to generate it" }
                ?? "none — semantic tokens only",
        ]

        var problems: [String] = []
        var changes: [Change] = []
        for (template, destination) in Self.templates {
            let path = Self.render(destination, values)
            if FileManager.default.fileExists(atPath: url(path).path) {
                problems.append("\(path) already exists")
            }
            let text = try read("Templates/Component/\(template)")
            changes.append(Change(kind: .create, path: path, contents: Self.render(text, values)))
        }
        if let existing = try existingDeclaration(of: "Qeetrix\(request.component)") {
            problems.append("Qeetrix\(request.component) is already declared in \(existing)")
        }

        let landing = try read(Self.landingPath)
        let topic = "- ``Qeetrix\(request.component)``"
        if landing.contains(topic) {
            problems.append("\(Self.landingPath) already lists Qeetrix\(request.component)")
        }
        let catalog = try read(Self.catalogPath)
        let line =
            "        ShowcaseEntry(\"\(values["pageID"]!)\", \"\(values["title"]!)\", .\(category.showcaseCase)) { \(request.component)Page() },"
        if catalog.contains("\(request.component)Page()") || catalog.contains("ShowcaseEntry(\"\(values["pageID"]!)\"") {
            problems.append("\(Self.catalogPath) already has a \(request.component) page")
        }
        guard problems.isEmpty else {
            throw GeneratorError(
                "Qeetrix\(request.component) already exists; nothing was changed:\n  " + problems.joined(separator: "\n  "))
        }
        guard catalog.contains(Self.catalogMarker + "\n") else {
            throw GeneratorError(
                "\(Self.catalogPath) has lost its marker line \"\(Self.catalogMarker.trimmingCharacters(in: .whitespaces))\".")
        }
        changes.append(
            Change(
                kind: .update, path: Self.catalogPath,
                contents: catalog.replacingOccurrences(of: Self.catalogMarker + "\n", with: line + "\n" + Self.catalogMarker + "\n")))
        changes.append(Change(kind: .update, path: Self.landingPath, contents: try Self.addTopic(topic, under: category.name, in: landing)))

        return changes
    }

    /// Makes the planned changes. Each file is checked again just before writing, so nothing is
    /// overwritten even if the tree changed after planning.
    public func apply(_ changes: [Change]) throws {
        for change in changes where change.kind == .create && FileManager.default.fileExists(atPath: url(change.path).path) {
            throw GeneratorError("\(change.path) appeared after planning; nothing was changed.")
        }
        for change in changes {
            let target = url(change.path)
            try FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
            try Data(change.contents.utf8).write(to: target, options: .atomic)
        }
    }

    // MARK: Validation

    static func validateName(_ name: String, what: String) throws {
        guard name.range(of: #"^[A-Z][A-Za-z0-9]*$"#, options: .regularExpression) != nil else {
            throw GeneratorError("The \(what) \"\(name)\" must be UpperCamelCase ASCII, e.g. IconButton.")
        }
        guard !name.hasPrefix("Qeetrix") else {
            throw GeneratorError("Give the \(what) without the Qeetrix prefix: \(name.dropFirst("Qeetrix".count)).")
        }
    }

    struct ManifestEntry {
        /// The family, kebab-case: `button`.
        let name: String
        let status: String
        let description: String
    }

    /// The manifest family that exports `part` (a component name such as `IconButton`).
    func manifestEntry(part: String) throws -> ManifestEntry {
        let families = try JSONSerialization.jsonObject(with: Data(try read(Self.manifestPath).utf8)) as? [[String: Any]] ?? []
        guard let entry = families.first(where: { ($0["parts"] as? [String] ?? []).contains(part) }) else {
            throw GeneratorError(
                "No family in \(Self.manifestPath) exports \(part). Pass the web part with --slug (for example --slug TextField).")
        }
        let name = entry["name"] as? String ?? ""
        let status = entry["status"] as? String ?? ""
        return ManifestEntry(name: name, status: status, description: "The \(part) of `@qeetrix/react`'s \(name) family (\(status)).")
    }

    /// The `component.<group>` token group of `@qeetrix/tokens` for the component, if it has one: the
    /// family's own group.
    func componentTokenGroup(slug: String, family: String) throws -> String? {
        let json = try JSONSerialization.jsonObject(with: Data(try read(Self.tokensPath).utf8)) as? [String: Any]
        let groups = (json?["component"] as? [String: Any]) ?? [:]
        return [slug, Self.kebab(family)].first { groups[$0] != nil }
    }

    func existingDeclaration(of type: String) throws -> String? {
        let sources = url("Sources/Qeetrix")
        guard let files = FileManager.default.enumerator(at: sources, includingPropertiesForKeys: nil) else { return nil }
        let pattern = #"(struct|enum|class|protocol|typealias|actor)\s+"# + type + #"\b"#
        // Both sides resolved, so a root behind a symlink (/var → /private/var) still gives relative paths.
        let base = root.resolvingSymlinksInPath().path
        var matches: [String] = []
        for case let file as URL in files where file.pathExtension == "swift" {
            let text = try String(contentsOf: file, encoding: .utf8)
            if text.range(of: pattern, options: .regularExpression) != nil {
                matches.append(String(file.resolvingSymlinksInPath().path.dropFirst(base.count + 1)))
            }
        }
        return matches.sorted().first
    }

    // MARK: Edits

    /// Adds `topic` as the last item under the `### <category>` heading of the landing page's topics,
    /// creating the heading — before `### Theme`, after the other component categories — if needed.
    static func addTopic(_ topic: String, under category: String, in landing: String) throws -> String {
        var lines = landing.components(separatedBy: "\n")
        if let heading = lines.firstIndex(of: "### \(category)") {
            var index = heading + 1
            var lastItem = heading + 1
            while index < lines.count, !lines[index].hasPrefix("#") {
                if lines[index].hasPrefix("- ") { lastItem = index }
                index += 1
            }
            lines.insert(topic, at: lastItem + 1)
        } else {
            guard let theme = lines.firstIndex(of: "### Theme") else {
                throw GeneratorError("\(landingPath) has no \"### Theme\" topic group to place a new category before.")
            }
            lines.insert(contentsOf: ["### \(category)", "", topic, ""], at: theme)
        }
        return lines.joined(separator: "\n")
    }

    // MARK: Names

    /// `IconButton` → `icon-button`, `OTPField` → `otp-field`.
    static func kebab(_ name: String) -> String {
        words(name).map { $0.lowercased() }.joined(separator: "-")
    }

    /// `IconButton` → `Icon button`.
    static func title(_ name: String) -> String {
        let parts = words(name)
        guard let first = parts.first else { return name }
        return ([first] + parts.dropFirst().map { $0.count > 1 && $0.uppercased() == $0 ? $0 : $0.lowercased() }).joined(separator: " ")
    }

    /// `icon-button` → `IconButton`.
    static func upperCamel(_ kebab: String) -> String {
        kebab.split(separator: "-").map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
    }

    static func words(_ name: String) -> [String] {
        var words: [String] = []
        var current = ""
        let characters = Array(name)
        for (index, character) in characters.enumerated() {
            let next = index + 1 < characters.count ? characters[index + 1] : nil
            let startsWord =
                character.isUppercase && !current.isEmpty
                && (current.last?.isLowercase == true || current.last?.isNumber == true || next?.isLowercase == true)
            if startsWord {
                words.append(current)
                current = ""
            }
            current.append(character)
        }
        if !current.isEmpty { words.append(current) }
        return words
    }

    static func render(_ template: String, _ values: [String: String]) -> String {
        values.keys.sorted().reduce(template) { text, key in
            text.replacingOccurrences(of: "{{\(key)}}", with: values[key]!)
        }
    }

    // MARK: Files

    func url(_ path: String) -> URL {
        root.appendingPathComponent(path)
    }

    func read(_ path: String) throws -> String {
        do {
            return try String(contentsOf: url(path), encoding: .utf8)
        } catch {
            throw GeneratorError("Cannot read \(path): \(error.localizedDescription)")
        }
    }
}
