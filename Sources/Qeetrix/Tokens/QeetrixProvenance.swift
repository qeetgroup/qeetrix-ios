import Foundation

/// Which upstream artifacts this build of Qeetrix was generated from — the record bundled as
/// `Metadata/token-provenance.json`. Useful in diagnostics and about screens, and for checking that two
/// platforms ship the same design-system release.
public struct QeetrixProvenance: Decodable, Hashable, Sendable {
    public struct Tokens: Decodable, Hashable, Sendable {
        /// The npm package the tokens come from, `@qeetrix/ui`.
        public let package: String
        public let version: String
        /// The qeetrix-ui commit the package was published from.
        public let gitHead: String
        /// The npm tarball's Subresource Integrity hash.
        public let integrity: String
        public let themes: [String]
        public let generatedTokens: Int
        public let excludedTokens: Int
    }

    public struct Icons: Decodable, Hashable, Sendable {
        public let package: String
        public let version: String
        public let repository: String
        public let commit: String
    }

    public struct Font: Decodable, Hashable, Sendable {
        /// The `QeetrixFontFamily` raw value.
        public let family: String
        public let webFamily: String
        public let postScriptName: String
        public let version: String
        public let repository: String
        public let tag: String
        /// sha256 of the bundled TTF.
        public let sha256: String
    }

    public let tokens: Tokens
    public let icons: Icons
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
