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
public struct QeetrixOption<Value: Hashable>: Identifiable {
    public let value: Value
    public let title: Text
    public let description: Text?
    public let isDisabled: Bool

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
    }
}
