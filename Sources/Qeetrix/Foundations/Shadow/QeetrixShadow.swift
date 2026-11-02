import SwiftUI

extension QeetrixShadow {
    /// The shadow layers for a colour scheme, in CSS order (the first layer is drawn on top).
    public func layers(for colorScheme: ColorScheme) -> [QeetrixShadowLayer] {
        colorScheme == .dark ? QeetrixDarkTokens.shadow(self) : QeetrixLightTokens.shadow(self)
    }
}

extension View {
    /// Draws a Qeetrix surface behind this view: the shadow's layers, the fill, and any inset
    /// highlight, all following the view's colour scheme. Shadows belong on floating layers only —
    /// menus, popovers, toasts and dialogs (design rules §12); page content is separated by tone and
    /// 1 pt lines.
    ///
    /// The layers are drawn the way CSS draws `box-shadow` — offset, spread, blurred with a standard
    /// deviation of half the blur radius, outer shadows clipped to outside the shape and inset ones to
    /// inside — so negative spreads and the 1 px ring layers render as on the web, which SwiftUI's
    /// `shadow(color:radius:x:y:)` cannot do.
    ///
    /// ```swift
    /// content
    ///     .padding(QeetrixSpace.insetLg)
    ///     .qeetrixShadow(.overlay, fill: .surfaceOverlay, in: RoundedRectangle(cornerRadius: QeetrixRadius.overlay))
    /// ```
    public func qeetrixShadow<S: InsettableShape>(_ shadow: QeetrixShadow, fill: QeetrixColor, in shape: S) -> some View {
        background(QeetrixShadowBackground(shadow: shadow, fill: fill, shape: shape))
    }

    /// The same surface with any fill.
    func qeetrixShadow<S: InsettableShape, F: ShapeStyle>(_ shadow: QeetrixShadow, fill: F, in shape: S) -> some View {
        background(QeetrixShadowBackground(shadow: shadow, fill: fill, shape: shape))
    }
}

struct QeetrixShadowBackground<S: InsettableShape, F: ShapeStyle>: View {
    let shadow: QeetrixShadow
    let fill: F
    let shape: S
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        // Reversed so the first CSS layer ends up on top.
        let layers = Array(shadow.layers(for: colorScheme).enumerated().reversed())
        ZStack {
            ZStack {
                ForEach(layers.filter { !$0.element.isInset }, id: \.offset) { _, layer in
                    shape.inset(by: -layer.spread)
                        .fill(layer.color)
                        .offset(x: layer.x, y: layer.y)
                        .blur(radius: layer.blur / 2)
                }
            }
            .mask { QeetrixOutside(shape: shape).fill(style: FillStyle(eoFill: true)) }

            shape.fill(fill)

            ZStack {
                ForEach(layers.filter { $0.element.isInset }, id: \.offset) { _, layer in
                    QeetrixOutside(shape: shape.inset(by: layer.spread))
                        .fill(layer.color, style: FillStyle(eoFill: true))
                        .offset(x: layer.x, y: layer.y)
                        .blur(radius: layer.blur / 2)
                }
            }
            .clipShape(shape)
        }
        .accessibilityHidden(true)
    }
}

/// Everything around a shape: a large rectangle with the shape cut out (with the even-odd rule).
struct QeetrixOutside<S: Shape>: Shape {
    let shape: S

    func path(in rect: CGRect) -> Path {
        var path = Path(rect.insetBy(dx: -512, dy: -512))
        path.addPath(shape.path(in: rect))
        return path
    }
}
