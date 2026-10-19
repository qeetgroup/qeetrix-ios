import SwiftUI

/// The sizes of ``QeetrixSpinner``, as on the web.
public enum QeetrixSpinnerSize: String, CaseIterable, Sendable {
    /// 16 pt.
    case sm
    /// 20 pt.
    case `default`
    /// 24 pt.
    case lg
    /// 32 pt.
    case xl

    /// The spinner's width and height.
    public var iconSize: QeetrixIconSize {
        switch self {
        case .sm: QeetrixIconSize(QeetrixWebScale.spacing(4))  // size-4
        case .default: QeetrixIconSize(QeetrixWebScale.spacing(5))  // size-5
        case .lg: QeetrixIconSize(QeetrixWebScale.spacing(6))  // size-6
        case .xl: QeetrixIconSize(QeetrixWebScale.spacing(8))  // size-8
        }
    }
}

/// An indeterminate busy indicator: the `loader-circle` icon, turning once a second in the tertiary
/// text colour.
///
/// ```swift
/// QeetrixSpinner()
/// QeetrixSpinner(size: .lg, label: Text("Loading invoices"))
/// ```
///
/// With Reduce Motion on it stands still. VoiceOver reads its label — "Loading" unless you give one;
/// name what is loading when the screen has more than one spinner. Inside a button use
/// ``QeetrixButton``'s `isLoading` instead, which reports the busy state on the button itself.
public struct QeetrixSpinner: View {
    let size: QeetrixSpinnerSize
    let label: Text?

    public init(size: QeetrixSpinnerSize = .default, label: Text? = nil) {
        self.size = size
        self.label = label
    }

    public var body: some View {
        QeetrixIcon(.loaderCircle, size: size.iconSize)
            .foregroundStyle(QeetrixColor.textTertiary)  // text-muted-foreground
            .qeetrixSpinning()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label ?? QeetrixStrings.loading)
    }
}
