import SwiftUI

/// One choice in a ``QeetrixRadioGroup``, a ``QeetrixSelect`` or a ``QeetrixChipGroup``: the value it
/// selects, its title, an optional description, and whether it can be chosen.
///
/// ```swift
/// let plans = [
///     QeetrixOption("Starter", value: Plan.starter),
///     QeetrixOption("Team", value: Plan.team, description: Text("Up to 25 members")),
///     QeetrixOption("Enterprise", value: Plan.enterprise, isDisabled: true),
/// ]
/// ```
///
/// The value's type is the selection's type, so a choice can only select a value the binding can hold.
/// For "nothing selected yet", make the selection optional (`Plan?`) and give the options `Plan?` values:
/// a selection no option has shows as unselected.
///
/// An option can carry an `icon`, which a ``QeetrixRadioGroup`` draws before its title: 16 pt in a row,
/// 20 pt in a 36 pt box on a tile. The other controls draw the title alone.
public struct QeetrixOption<Value: Hashable>: Identifiable {
    public let value: Value
    public let title: Text
    public let description: Text?
    public let isDisabled: Bool
    /// The icon a radio group draws before the title, or `nil`.
    public let icon: QeetrixIconName?

    public var id: Value { value }

    /// An option with a localised title.
    public init(_ titleKey: LocalizedStringKey, value: Value, description: Text? = nil, isDisabled: Bool = false) {
        self.init(title: Text(titleKey), value: value, description: description, isDisabled: isDisabled)
    }

    /// An option with a title shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, value: Value, description: Text? = nil, isDisabled: Bool = false) {
        self.init(title: Text(title), value: value, description: description, isDisabled: isDisabled)
    }

    /// An option with a `Text` title.
    public init(title: Text, value: Value, description: Text? = nil, isDisabled: Bool = false) {
        self.value = value
        self.title = title
        self.description = description
        self.isDisabled = isDisabled
        icon = nil
    }

    /// An option with a localised title and an icon, for a ``QeetrixRadioGroup``'s rows or tiles.
    public init(_ titleKey: LocalizedStringKey, value: Value, description: Text? = nil, icon: QeetrixIconName, isDisabled: Bool = false) {
        self.init(title: Text(titleKey), value: value, description: description, icon: icon, isDisabled: isDisabled)
    }

    /// An option with a title shown as given, without localisation, and an icon.
    public init<S: StringProtocol>(_ title: S, value: Value, description: Text? = nil, icon: QeetrixIconName, isDisabled: Bool = false) {
        self.init(title: Text(title), value: value, description: description, icon: icon, isDisabled: isDisabled)
    }

    /// An option with a `Text` title and an icon.
    public init(title: Text, value: Value, description: Text? = nil, icon: QeetrixIconName, isDisabled: Bool = false) {
        self.value = value
        self.title = title
        self.description = description
        self.isDisabled = isDisabled
        self.icon = icon
    }
}
