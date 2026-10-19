import SwiftUI

/// The field rhythm the web's `Field` family shares — label, description and messages — so every
/// labelled control reads the same.
enum QeetrixFieldMetrics {
    /// `Label` / `FieldLabel`: `text-sm leading-snug font-medium`.
    static let labelType = QeetrixComponentType.ui(
        QeetrixWebScale.textSM, .medium, lineHeight: QeetrixWebScale.leadingSnug, scalesLike: .subheadline)
    /// The optional indicator: the label's size, `font-normal`.
    static let optionalType = QeetrixComponentType.ui(
        QeetrixWebScale.textSM, .regular, lineHeight: QeetrixWebScale.leadingSnug, scalesLike: .subheadline)
    /// `FieldLegend variant="legend"`: `font-heading text-base font-medium`.
    static let legendType = QeetrixComponentType.heading(QeetrixWebScale.textBase, .medium, scalesLike: .headline)
    /// `FieldDescription` and the messages: `text-caption font-normal`.
    static let captionType = QeetrixTypeSpec(.caption)
    /// A vertical field's gap between label, control, description and message: `gap-1.5`.
    static let gap = QeetrixWebScale.spacing(1.5)
    /// A message's icon: `[&>svg]:size-3.5`, nudged down 1 pt (`mt-px`) to sit on the first line.
    static let messageIconSize = QeetrixIconSize(QeetrixWebScale.spacing(3.5))
}
