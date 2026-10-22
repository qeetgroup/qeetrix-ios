import SwiftUI

extension View {
    /// Frames an icon in a square `side` points wide at the default text size — an icon button, a field
    /// action. The icon scales with Dynamic Type, so the square grows with it and keeps the same inset
    /// around it, as a native button grows with its symbol; a fixed square would let the icon spill over
    /// the control's edge and its neighbours at the accessibility sizes.
    ///
    /// - Parameters:
    ///   - side: The web's square, in points: the size at the default text size, and the minimum.
    ///   - icon: The icon's size at the default text size.
    func qeetrixIconSquare(_ side: CGFloat, icon: CGFloat) -> some View {
        padding(max(0, (side - icon) / 2))
            .frame(minWidth: side, minHeight: side)
    }
}
