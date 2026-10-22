import Foundation
import Testing

@testable import QeetrixGenCore

@Suite("Bill of materials")
struct SBOMTests {
    func components(_ sbom: String) throws -> [[String: Any]] {
        let json = try #require(try JSONSerialization.jsonObject(with: Data(sbom.utf8)) as? [String: Any])
        #expect(json["bomFormat"] as? String == "CycloneDX")
        #expect(json["specVersion"] as? String == "1.5")
        return try #require(json["components"] as? [[String: Any]])
    }

    @Test("Lists the bundled fonts, icons and tokens as required, and test-only packages as excluded")
    func contents() throws {
        let all = try components(try SBOM.render(root: SnapshotTests.root, version: "0.0.0-test"))
        let required = all.filter { $0["scope"] as? String == "required" }.compactMap { $0["bom-ref"] as? String }
        #expect(Set(required) == ["font-sans", "font-mono", "qeetrix-icons", "qeetrix-ui"])
        let excluded = all.filter { $0["scope"] as? String == "excluded" }.compactMap { $0["name"] as? String }
        #expect(excluded.contains("swift-snapshot-testing"))
        let fonts = all.filter { ($0["bom-ref"] as? String)?.hasPrefix("font-") == true }
        for font in fonts {
            #expect((font["licenses"] as? [[String: Any]])?.first?["expression"] as? String == "OFL-1.1")
            #expect(((font["hashes"] as? [[String: Any]])?.first?["content"] as? String)?.count == 64, "A SHA-256 digest")
        }
    }

    @Test("The same inputs give the same file: no timestamp, no random serial number")
    func deterministic() throws {
        let first = try SBOM.render(root: SnapshotTests.root, version: "0.0.0-test")
        #expect(first == (try SBOM.render(root: SnapshotTests.root, version: "0.0.0-test")))
        #expect(!first.contains("timestamp") && !first.contains("serialNumber"))
    }

    @Test("An npm integrity value becomes a hex SHA-512 digest")
    func integrity() {
        #expect(
            SBOM.hex(fromIntegrity: "sha512-" + Data(repeating: 0xAB, count: 64).base64EncodedString())
                == String(repeating: "ab", count: 64))
        #expect(SBOM.hex(fromIntegrity: "sha1-abc") == nil)
    }
}
