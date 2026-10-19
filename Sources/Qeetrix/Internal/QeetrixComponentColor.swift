import SwiftUI

/// A component colour token. Most name one semantic colour in both themes; the rest are a semantic
/// colour in one theme and a mixed or transparent value in the other (for example the outline button's
/// dark background, `color-mix` of the surface at 12%). Internal: components consume it, and the public
/// colour API stays ``QeetrixColor``.
struct QeetrixComponentColor: ShapeStyle, Hashable, Sendable {
    enum Value: Hashable, Sendable {
        case semantic(QeetrixColor)
        case rgba(QeetrixRGBA)

        func rgba(for colorScheme: ColorScheme) -> QeetrixRGBA {
            switch self {
            case .semantic(let color): color.rgba(for: colorScheme)
            case .rgba(let rgba): rgba
            }
        }
    }

    let light: Value
    let dark: Value

    init(_ color: QeetrixColor) {
        light = .semantic(color)
        dark = .semantic(color)
    }

    init(light: Value, dark: Value) {
        self.light = light
        self.dark = dark
    }

    func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        rgba(for: environment.colorScheme).resolved
    }

    func color(for colorScheme: ColorScheme) -> Color {
        rgba(for: colorScheme).color
    }

    func rgba(for colorScheme: ColorScheme) -> QeetrixRGBA {
        colorScheme == .dark ? dark.rgba(for: .dark) : light.rgba(for: .light)
    }
}
