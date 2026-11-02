import Foundation
import Testing

@testable import QeetrixGenCore

/// `new-component`, run in throwaway copies of the repository's real inputs — the templates, the pinned
/// `@qeetrix/react` manifest and `@qeetrix/tokens` build, the pins, the DocC landing page and the
/// showcase catalogue — never in the repository itself.
@Suite("Component scaffold")
struct ComponentScaffoldTests {
    /// A temporary root holding copies of the files the scaffold reads.
    struct Fixture {
        let root: URL

        init() throws {
            root = FileManager.default.temporaryDirectory.appendingPathComponent("qeetrix-scaffold-\(UUID().uuidString)")
            let inputs = [
                "Templates/Component/Component.swift.template", "Templates/Component/ComponentTests.swift.template",
                "Templates/Component/ComponentSnapshotTests.swift.template", "Templates/Component/Component.md.template",
                "Templates/Component/ComponentPage.swift.template", ComponentScaffold.manifestPath, ComponentScaffold.tokensPath,
                Lock.pinsPath, ComponentScaffold.landingPath, ComponentScaffold.catalogPath,
            ]
            for path in inputs {
                let target = root.appendingPathComponent(path)
                try FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
                try FileManager.default.copyItem(at: SnapshotTests.root.appendingPathComponent(path), to: target)
            }
            try write("Sources/Qeetrix/Components/Button/Button/QeetrixButton.swift", "public struct QeetrixButton {}\n")
            // The landing page and catalogue are the real ones, which grow as components are built: forget
            // the ones these tests scaffold, so each test sees them as new.
            let marks: [(path: String, mark: (String) -> String)] = [
                (ComponentScaffold.landingPath, { name in "``Qeetrix\(name)``" }),
                (ComponentScaffold.catalogPath, { name in "\(name)Page()" }),
            ]
            for (path, mark) in marks {
                let lines = try read(path).components(separatedBy: "\n")
                let kept = lines.filter { line in !Self.scaffolded.contains { line.contains(mark($0)) } }
                try write(path, kept.joined(separator: "\n"))
            }
        }

        /// The components the tests scaffold.
        static let scaffolded = ["Slider", "TextArea", "CommandPalette", "Calendar", "Kbd"]

        func write(_ path: String, _ text: String) throws {
            let url = root.appendingPathComponent(path)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try Data(text.utf8).write(to: url)
        }

        func read(_ path: String) throws -> String {
            try String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
        }

        /// Every file under the root with its bytes, to prove a run changed nothing.
        func tree() throws -> [String: Data] {
            var files: [String: Data] = [:]
            let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: [.isRegularFileKey])
            while let url = enumerator?.nextObject() as? URL {
                if (try url.resourceValues(forKeys: [.isRegularFileKey])).isRegularFile == true {
                    files[String(url.path.dropFirst(root.path.count))] = try Data(contentsOf: url)
                }
            }
            return files
        }

        func remove() {
            try? FileManager.default.removeItem(at: root)
        }
    }

    @Test("A new component gets every file, its DocC topic and its showcase entry")
    func scaffold() throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let scaffold = ComponentScaffold(root: fixture.root)
        try scaffold.apply(try scaffold.plan(.init(family: "Slider", component: "Slider", category: "Forms & inputs")))

        let source = try fixture.read("Sources/Qeetrix/Components/Slider/Slider/QeetrixSlider.swift")
        #expect(source.contains("public struct QeetrixSlider: View"))
        #expect(source.contains("#error(\"QeetrixSlider is a scaffold"), "An unfinished scaffold must not build")
        #expect(source.contains("https://ui.qeet.in/components/slider"))
        #expect(!source.contains("{{"), "Every placeholder is filled")
        #expect(try fixture.read("Tests/QeetrixTests/Components/Slider/SliderTests.swift").contains("Issue.record("))
        #expect(try fixture.read("Tests/QeetrixSnapshotTests/Slider/SliderSnapshotTests.swift").contains("assertSpecimen("))
        #expect(try fixture.read("Sources/Qeetrix/Qeetrix.docc/Components/Slider.md").hasPrefix("# ``Qeetrix/QeetrixSlider``"))
        #expect(try fixture.read("Examples/QeetrixShowcase/QeetrixShowcase/Components/Slider/SliderPage.swift").contains("#error("))

        let landing = try fixture.read(ComponentScaffold.landingPath)
        let forms = try #require(landing.range(of: "### Forms & inputs"))
        let next = try #require(landing[forms.upperBound...].range(of: "### "))
        #expect(landing[forms.upperBound..<next.lowerBound].contains("- ``QeetrixSlider``"))
        let catalog = try fixture.read(ComponentScaffold.catalogPath)
        #expect(
            catalog.contains("ShowcaseEntry(\"slider\", \"Slider\", .forms) { SliderPage() },\n" + ComponentScaffold.catalogMarker))
    }

    @Test("A web part named differently from the iOS component, in a family without component tokens")
    func slugAndFamily() throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let scaffold = ComponentScaffold(root: fixture.root)
        let changes = try scaffold.plan(.init(family: "Input", component: "TextArea", slug: "Textarea", category: "Forms & inputs"))
        let source = try #require(changes.first { $0.path == "Sources/Qeetrix/Components/Input/TextArea/QeetrixTextArea.swift" })
        #expect(source.contents.contains("none — semantic tokens only"))
        #expect(source.contents.contains("https://ui.qeet.in/components/textarea"))
        #expect(!changes.contains { $0.path == Lock.pinsPath }, "the scaffold never edits the pins")
    }

    @Test("A family with component tokens in @qeetrix/tokens names them")
    func componentTokens() throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        // A family iOS doesn't implement yet (timeline and sidebar now exist).
        let changes = try ComponentScaffold(root: fixture.root).plan(
            .init(family: "CommandPalette", component: "CommandPalette", category: "Overlays"))
        let source = try #require(changes.first { $0.path.hasSuffix("QeetrixCommandPalette.swift") })
        #expect(source.contents.contains("component.command-palette.* in @qeetrix/tokens"))
    }

    @Test("A category without components yet gets its heading, before the foundation topics")
    func newCategory() throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        // Empty "Date & time" in the fixture, whatever the real landing page and catalogue hold by now.
        var lines = try fixture.read(ComponentScaffold.landingPath).components(separatedBy: "\n")
        if let start = lines.firstIndex(of: "### Date & time") {
            let end = lines[(start + 1)...].firstIndex { $0.hasPrefix("### ") } ?? lines.endIndex
            lines.removeSubrange(start..<end)
        }
        try fixture.write(ComponentScaffold.landingPath, lines.joined(separator: "\n"))
        let catalog = try fixture.read(ComponentScaffold.catalogPath).components(separatedBy: "\n")
        try fixture.write(ComponentScaffold.catalogPath, catalog.filter { !$0.contains("CalendarPage()") }.joined(separator: "\n"))
        let changes = try ComponentScaffold(root: fixture.root).plan(
            .init(family: "Calendar", component: "Calendar", category: "Date & time"))
        let landing = try #require(changes.first { $0.path == ComponentScaffold.landingPath }).contents
        #expect(landing.contains("### Date & time\n\n- ``QeetrixCalendar``\n\n### Theme"))
    }

    @Test("Running it twice changes nothing the second time")
    func rerun() throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let scaffold = ComponentScaffold(root: fixture.root)
        let request = ComponentScaffold.Request(family: "Slider", component: "Slider", category: "Forms & inputs")
        try scaffold.apply(try scaffold.plan(request))
        let tree = try fixture.tree()
        #expect(throws: GeneratorError.self) { try scaffold.plan(request) }
        #expect(try fixture.tree() == tree)
    }

    @Test("Any existing piece stops the run, with every reason, before anything is written")
    func duplicates() throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        try fixture.write("Tests/QeetrixTests/Components/Slider/SliderTests.swift", "// mine\n")
        let tree = try fixture.tree()
        do {
            _ = try ComponentScaffold(root: fixture.root).plan(.init(family: "Slider", component: "Slider", category: "Forms & inputs"))
            Issue.record("an existing test file must stop the run")
        } catch let error as GeneratorError {
            #expect(error.message.contains("SliderTests.swift already exists"))
        }
        #expect(try fixture.tree() == tree)
        #expect(try fixture.read("Tests/QeetrixTests/Components/Slider/SliderTests.swift") == "// mine\n")

        // A type declared anywhere in the library, under any folder.
        do {
            _ = try ComponentScaffold(root: fixture.root).plan(.init(family: "Button", component: "Button", category: "Actions"))
            Issue.record("an existing declaration must stop the run")
        } catch let error as GeneratorError {
            #expect(
                error.message.contains("QeetrixButton is already declared in Sources/Qeetrix/Components/Button/Button/QeetrixButton.swift"))
        }
    }

    @Test("Planning writes nothing, and the same request gives the same bytes")
    func dryRunAndDeterminism() throws {
        let first = try Fixture()
        let second = try Fixture()
        defer {
            first.remove()
            second.remove()
        }
        let request = ComponentScaffold.Request(family: "Kbd", component: "Kbd", category: "Data display")
        let tree = try first.tree()
        let a = try ComponentScaffold(root: first.root).plan(request)
        #expect(try first.tree() == tree)
        let b = try ComponentScaffold(root: second.root).plan(request)
        #expect(a == b)
    }

    @Test(
        "Names, families, slugs and categories are checked against the manifest",
        arguments: [
            ComponentScaffold.Request(family: "Checkbox", component: "checkbox", category: "Forms & inputs"),
            ComponentScaffold.Request(family: "Checkbox", component: "Check-box", category: "Forms & inputs"),
            ComponentScaffold.Request(family: "Checkbox", component: "QeetrixCheckbox", category: "Forms & inputs"),
            ComponentScaffold.Request(family: "Button", component: "Checkbox", category: "Forms & inputs"),
            ComponentScaffold.Request(family: "Checkbox", component: "Tickbox", category: "Forms & inputs"),
            ComponentScaffold.Request(family: "Checkbox", component: "Checkbox", category: "Forms"),
        ])
    func rejects(request: ComponentScaffold.Request) throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let tree = try fixture.tree()
        #expect(throws: GeneratorError.self) { try ComponentScaffold(root: fixture.root).plan(request) }
        #expect(try fixture.tree() == tree)
    }

    @Test("Kebab case and titles keep acronyms together")
    func names() {
        #expect(ComponentScaffold.kebab("IconButton") == "icon-button")
        #expect(ComponentScaffold.kebab("OTPField") == "otp-field")
        #expect(ComponentScaffold.kebab("QRCode") == "qr-code")
        #expect(ComponentScaffold.title("IconButton") == "Icon button")
        #expect(ComponentScaffold.title("OTPField") == "OTP field")
        #expect(ComponentScaffold.upperCamel("icon-button") == "IconButton")
    }
}
