import SwiftUI

private struct QeetrixDensityKey: EnvironmentKey {
    static let defaultValue: QeetrixDensity = .default
}

extension EnvironmentValues {
    /// The control density in effect — the counterpart of the web's `DensityProvider`. Components read
    /// their control and row metrics from it.
    public var qeetrixDensity: QeetrixDensity {
        get { self[QeetrixDensityKey.self] }
        set { self[QeetrixDensityKey.self] = newValue }
    }
}

extension View {
    /// Sets the control density for this view hierarchy.
    public func qeetrixDensity(_ density: QeetrixDensity) -> some View {
        environment(\.qeetrixDensity, density)
    }
}
