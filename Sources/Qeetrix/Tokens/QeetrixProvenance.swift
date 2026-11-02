import Foundation

/// Which upstream artifacts this build of Qeetrix was generated from — the record bundled as
/// `Metadata/token-provenance.json`. Useful in diagnostics and about screens, and for checking that two
/// platforms ship the same design-system release.
public struct QeetrixProvenance: Decodable, Hashable, Sendable {
    /// One npm package, as the registry published it.
    public struct Package: Decodable, Hashable, Sendable {
        /// `@qeetrix/tokens`, `@qeetrix/icons` or `@qeetrix/react`.
        public let package: String
        public let version: String
        /// The commit the package was published from.
        public let gitHead: String
        /// The npm tarball's Subresource Integrity hash.
        public let integrity: String
    }

    public struct Tokens: Decodable, Hashable, Sendable {
        /// `@qeetrix/tokens`.
        public let package: String
        public let version: String
        public let gitHead: String
        public let integrity: String
        /// The colour schemes of its resolver, default first.
        public let colorSchemes: [String]
        /// The densities of its resolver, default first.
        public let densities: [String]
        public let generatedTokens: Int
        public let excludedTokens: Int
    }

    public struct Font: Decodable, Hashable, Sendable {
        /// The `QeetrixFontFamily` raw value.
        public let family: String
        public let webFamily: String
        public let postScriptName: String
        public let version: String
        /// The package the font ships in, and the TTF's path there.
        public let package: String
        public let source: String
        /// sha256 of the WOFF2 the web loads, which the package made the TTF from.
        public let woff2SHA256: String
        /// sha256 of the bundled TTF.
        public let sha256: String
    }

    public let tokens: Tokens
    /// `@qeetrix/icons`, the drawings.
    public let icons: Package
    /// `@qeetrix/react`, the components iOS follows.
    public let components: Package
    public let fonts: [Font]

    /// The record bundled with the library.
    public static func bundled() throws -> QeetrixProvenance {
        guard let url = Bundle.module.url(forResource: "token-provenance", withExtension: "json", subdirectory: "Metadata") else {
            throw CocoaError(
                .fileNoSuchFile, userInfo: [NSLocalizedDescriptionKey: "Metadata/token-provenance.json is missing from the Qeetrix bundle."]
            )
        }
        return try JSONDecoder().decode(QeetrixProvenance.self, from: Data(contentsOf: url))
    }
}
