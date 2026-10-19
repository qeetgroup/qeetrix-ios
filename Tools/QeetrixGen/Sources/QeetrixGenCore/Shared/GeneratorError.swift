/// Every failure the tool reports. The message names the token, file or icon at fault, because a
/// generator that fails without saying where is a generator people learn to work around.
public struct GeneratorError: Error, CustomStringConvertible, Equatable {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var description: String { message }
}
