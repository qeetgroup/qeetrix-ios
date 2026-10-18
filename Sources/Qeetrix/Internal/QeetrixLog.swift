import os

/// The library's unified-logging channels. Failures that degrade output — a font that did not
/// register, an icon drawing that is missing — are logged rather than swallowed.
enum QeetrixLog {
    static let fonts = Logger(subsystem: "in.qeet.qeetrix", category: "fonts")
    static let icons = Logger(subsystem: "in.qeet.qeetrix", category: "icons")
}
