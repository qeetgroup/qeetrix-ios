import SwiftUI

/// The text a component sets: always a typography role, sometimes at another weight, as
/// `@qeetrix/react`'s CSS writes it (`font: var(--qx-typography-label-md)`, then a `font-weight`
/// from another role for a selected state). Each is a ``QeetrixTypeSpec``, so it gets the role's
/// font, letter style, Dynamic Type curve and Bold Text handling.
enum QeetrixComponentType {
    /// A role as the web sets it.
    static func role(_ role: QeetrixTextRole) -> QeetrixTypeSpec {
        QeetrixTypeSpec(role)
    }

    /// A role at another weight: `label.md` at `title.sm`'s 600 for a selected tab.
    static func role(_ role: QeetrixTextRole, _ weight: QeetrixFontWeight) -> QeetrixTypeSpec {
        QeetrixTypeSpec(role, weight: weight)
    }

    /// A role at its token size whatever the Dynamic Type setting, for text inside a fixed-size
    /// graphic (avatar initials) that must not outgrow its frame.
    static func fixed(_ role: QeetrixTextRole) -> QeetrixTypeSpec {
        QeetrixTypeSpec(role).fixedSize
    }
}
