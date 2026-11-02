import SwiftUI

/// Which characters a code takes, as `@qeetrix/react`'s OTPInput `validationType` (Base UI OTP Field).
public enum QeetrixOTPValidationType: String, CaseIterable, Sendable {
    /// Digits only, on the number pad (the default).
    case numeric
    /// Letters and digits, for recovery codes.
    case alphanumeric
}

/// The height of ``QeetrixOTPInput``'s slots, as `@qeetrix/react`'s `OTPInputSize`.
public enum QeetrixOTPInputSize: String, CaseIterable, Sendable {
    /// An input's height (`size.control.lg`), for consoles; `title.md` characters.
    case md
    /// 16 pt taller, for sign-in pages; `title.lg` characters.
    case lg
}

/// A one-time code, one slot per character — `@qeetrix/react`'s OTPInput, in a Field when it has a
/// label.
///
/// ```swift
/// QeetrixOTPInput("Verification code", code: $code, size: .lg) { verify($0) }
/// QeetrixOTPInput("Recovery code", code: $recovery, length: 10, groups: [5, 5], validationType: .alphanumeric)
/// ```
///
/// Each slot is the Qeetrix field box with its character centred in tabular figures. Like every field
/// it spans its container and the slots share the width, shrinking to a 24 pt minimum, so its edges
/// line up with the fields and buttons around it. `groups` splits the slots with a short rule
/// (`[3, 3]` shows 123 – 456). The focused slot shows the Ember frame; with an error every slot shows
/// the danger frame — clear the code after a failed attempt. Typing moves on, deleting moves back, a
/// paste or SMS AutoFill fills every slot, and `onValueComplete` runs when the code is full. VoiceOver
/// reads one text field named by the label ("One-time code" without one).
public struct QeetrixOTPInput: View {
    let context: QeetrixFieldContext?
    let isOptional: Bool
    let isLabelHidden: Bool
    let code: Binding<String>
    let length: Int
    let groups: [Int]
    let size: QeetrixOTPInputSize
    let validationType: QeetrixOTPValidationType
    let onValueComplete: (@MainActor (String) -> Void)?

    public init(
        _ titleKey: LocalizedStringKey,
        code: Binding<String>,
        length: Int = 6,
        groups: [Int] = [],
        size: QeetrixOTPInputSize = .md,
        validationType: QeetrixOTPValidationType = .numeric,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        onValueComplete: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(titleKey), code: code, length: length, groups: groups, size: size, validationType: validationType,
            description: description, error: error, isRequired: isRequired, isOptional: isOptional, onValueComplete: onValueComplete)
    }

    public init<S: StringProtocol>(
        _ title: S,
        code: Binding<String>,
        length: Int = 6,
        groups: [Int] = [],
        size: QeetrixOTPInputSize = .md,
        validationType: QeetrixOTPValidationType = .numeric,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        onValueComplete: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(title), code: code, length: length, groups: groups, size: size, validationType: validationType,
            description: description, error: error, isRequired: isRequired, isOptional: isOptional, onValueComplete: onValueComplete)
    }

    public init(
        label: Text,
        code: Binding<String>,
        length: Int = 6,
        groups: [Int] = [],
        size: QeetrixOTPInputSize = .md,
        validationType: QeetrixOTPValidationType = .numeric,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        onValueComplete: (@MainActor (String) -> Void)? = nil
    ) {
        context = QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired)
        self.isOptional = isOptional
        isLabelHidden = false
        self.code = code
        self.length = max(1, length)
        self.groups = groups
        self.size = size
        self.validationType = validationType
        self.onValueComplete = onValueComplete
    }

    /// A code without a visible label, for a screen whose heading names it; VoiceOver calls it
    /// "One-time code". An error still shows under it.
    public init(
        code: Binding<String>,
        length: Int = 6,
        groups: [Int] = [],
        size: QeetrixOTPInputSize = .md,
        validationType: QeetrixOTPValidationType = .numeric,
        error: String? = nil,
        onValueComplete: (@MainActor (String) -> Void)? = nil
    ) {
        context = error.map { QeetrixFieldContext(label: QeetrixStrings.oneTimeCode, error: $0) }
        isOptional = false
        isLabelHidden = true
        self.code = code
        self.length = max(1, length)
        self.groups = groups
        self.size = size
        self.validationType = validationType
        self.onValueComplete = onValueComplete
    }

    public var body: some View {
        let field = QeetrixOTPField(
            code: code, length: length, groups: groups, size: size, validationType: validationType, onValueComplete: onValueComplete)
        if let context {
            QeetrixFieldLayout(context: context, isOptional: isOptional, isLabelHidden: isLabelHidden) { field }
        } else {
            field
        }
    }
}

struct QeetrixOTPField: View {
    let code: Binding<String>
    let length: Int
    let groups: [Int]
    let size: QeetrixOTPInputSize
    let validationType: QeetrixOTPValidationType
    let onValueComplete: (@MainActor (String) -> Void)?
    @State private var text = ""
    @FocusState private var isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context

    var body: some View {
        slots
            .overlay {
                // An empty prompt: without one the field would draw its label as a placeholder over the slots.
                TextField(text: $text, prompt: Text(verbatim: "")) { context?.label ?? QeetrixStrings.oneTimeCode }
                    .qeetrixTextInputTraits(.oneTimeCode(validationType))
                    .focused($isFocused)
                    // The slots draw the code; the field itself shows nothing, caret included.
                    .foregroundStyle(.clear)
                    .tint(.clear)
                    .privacySensitive()
                    .qeetrixFieldControlAccessibility(fallbackLabel: QeetrixStrings.oneTimeCode)
            }
            .contentShape(Rectangle())
            .onTapGesture { if isEnabled { isFocused = true } }
            .onAppear { text = code.wrappedValue }
            .onChange(of: text) { _, newText in
                let accepted = QeetrixOTPCode.accept(newText, previous: code.wrappedValue, length: length, validationType: validationType)
                if accepted != newText { text = accepted }
                guard accepted != code.wrappedValue else { return }
                let wasComplete = code.wrappedValue.count == length
                code.wrappedValue = accepted
                if accepted.count == length && !wasComplete { onValueComplete?(accepted) }
            }
            .onChange(of: code.wrappedValue) { _, newCode in
                // The app cleared or set the code.
                if newCode != text { text = newCode }
            }
    }

    /// The indexes that start a new group, after the first.
    var breaks: Set<Int> {
        var breaks: Set<Int> = []
        var at = 0
        for group in groups {
            at += group
            if at < length { breaks.insert(at) }
        }
        return breaks
    }

    private var slots: some View {
        let characters = Array(code.wrappedValue)
        let active = min(characters.count, length - 1)
        let height = density.sizeControlLg + (size == .lg ? 16 : 0)
        let breaks = self.breaks
        return HStack(spacing: QeetrixSpace.gapSm) {
            ForEach(0..<length, id: \.self) { index in
                if breaks.contains(index) {
                    Rectangle()
                        .fill(QeetrixColor.borderStrong)
                        .frame(width: QeetrixSpace.gapSm, height: QeetrixBorderWidth.strong)
                }
                QeetrixOTPSlot(
                    character: index < characters.count ? characters[index] : nil,
                    state: QeetrixInputState(
                        isEnabled: isEnabled, isReadOnly: false, isFocused: isFocused && index == active, isHovered: false,
                        isInvalid: context?.invalid ?? false),
                    type: QeetrixOTPMetrics.characterType(size),
                    height: height)
            }
        }
        // A code reads left to right in every script; the row still spans its container.
        .environment(\.layoutDirection, .leftToRight)
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }
}

private struct QeetrixOTPSlot: View {
    let character: Character?
    let state: QeetrixInputState
    let type: QeetrixTypeSpec
    let height: CGFloat

    var body: some View {
        Text(verbatim: character.map(String.init) ?? "")
            .qeetrixTypeEnvironment(type)
            .monospacedDigit()
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            // flex 1 1 0, at least the 24 pt minimum target.
            .frame(minWidth: QeetrixSize.targetMin, maxWidth: .infinity, minHeight: height)
            .qeetrixInputSurface(state)
    }
}

enum QeetrixOTPMetrics {
    /// `title.md` (`title.lg` at `lg`), in the A11y letter style: otp-input.css sets
    /// `font-geometry-body` after the font.
    static func characterType(_ size: QeetrixOTPInputSize) -> QeetrixTypeSpec {
        let role: QeetrixTextRole = size == .lg ? .titleLg : .titleMd
        let tokens = role.tokens
        return QeetrixTypeSpec(
            QeetrixTextRoleTokens(
                family: tokens.family, size: tokens.size, weight: tokens.weight, lineHeight: tokens.lineHeight,
                letterSpacing: tokens.letterSpacing, geometry: .body),
            scalesLike: role.textStyle)
    }
}

// A code's characters, on the public ``QeetrixOTPCode`` that shows a code (QTRX-108); `nonisolated`, as
// the number field's parser reads digits with them outside the main actor.
extension QeetrixOTPCode {
    /// The code after an edit: only the `validationType` characters (digits from any script entered as 0–9), at most `length`
    /// of them. When the edit brought in a whole code at once — a paste or AutoFill into a part-filled
    /// field — the new code replaces the old, as on the web; otherwise characters past `length` are dropped.
    nonisolated static func accept(_ text: String, previous: String, length: Int, validationType: QeetrixOTPValidationType) -> String {
        let cleaned = normalise(text, validationType: validationType)
        guard cleaned.count > length else { return cleaned }
        let inserted = cleaned.hasPrefix(previous) ? String(cleaned.dropFirst(previous.count)) : cleaned
        return String((inserted.count >= length ? inserted : cleaned).prefix(length))
    }

    nonisolated static func normalise(_ text: String, validationType: QeetrixOTPValidationType) -> String {
        var result = ""
        for character in text {
            if let digit = decimalDigit(character) {
                result.append(Character(String(digit)))
            } else if validationType == .alphanumeric, character.isASCII, character.isLetter {
                result.append(character)
            }
        }
        return result
    }

    /// The value of a decimal digit in any script — 7, ٧, ७ — and nil for anything else, including
    /// numerals that are not decimal digits, such as Ⅶ.
    nonisolated static func decimalDigit(_ character: Character) -> Int? {
        guard character.unicodeScalars.count == 1, let scalar = character.unicodeScalars.first,
            scalar.properties.numericType == .decimal
        else { return nil }
        return character.wholeNumberValue
    }
}
