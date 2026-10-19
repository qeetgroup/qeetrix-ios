import SwiftUI

/// The characters a one-time code is made of.
public enum QeetrixOTPCharacters: String, CaseIterable, Sendable {
    /// 0–9, with the number pad — the web's only form. Digits typed in another script, such as
    /// Arabic-Indic, are entered as 0–9.
    case digits
    /// A–Z, a–z and 0–9, with the ASCII keyboard capitalising as it types. An iOS addition for services
    /// that send letters as well as digits.
    case alphanumeric
}

/// A one-time-code field — the web's `OTPInput`, in a field.
///
/// ```swift
/// QeetrixOTPInput("Verification code", code: $code, description: Text("Sent to •••• 4821")) { completed in
///     verify(completed)
/// }
/// ```
///
/// One native text field holds the code: the cells only draw it. So the system's one-time-code AutoFill
/// (from Messages and Mail), paste, the edit menu and VoiceOver all work on the code as one value, as the
/// web's single-tab-stop group does. VoiceOver reads one field, named by the label — "One-time code"
/// without one — rather than a row of cells.
///
/// - The code is a `String`, so leading zeros are kept. Characters outside `characters` are dropped, and
///   the code never grows past `length`; a pasted or autofilled code of full length replaces a partial
///   one.
/// - `onComplete` runs once each time the code becomes complete. Nothing is submitted automatically: call
///   your own submit from it if you want that.
/// - Set the binding to `""` to clear it.
/// - `groupSize` draws a divider every so many cells — `3` shows a six-digit code as 123 – 456.
/// - A code reads left to right in every script, so the cells keep that order in right-to-left layouts,
///   aligned to the leading edge.
///
/// Generating, checking and storing codes are the app's. The component never logs or describes the code.
public struct QeetrixOTPInput: View {
    let context: QeetrixFieldContext?
    let isOptional: Bool
    let code: Binding<String>
    let length: Int
    let characters: QeetrixOTPCharacters
    let groupSize: Int?
    let onComplete: (@MainActor (String) -> Void)?

    /// A code field with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        code: Binding<String>,
        length: Int = 6,
        characters: QeetrixOTPCharacters = .digits,
        groupSize: Int? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        onComplete: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(titleKey), code: code, length: length, characters: characters, groupSize: groupSize, description: description,
            message: message, isRequired: isRequired, isOptional: isOptional, onComplete: onComplete)
    }

    /// A code field with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        code: Binding<String>,
        length: Int = 6,
        characters: QeetrixOTPCharacters = .digits,
        groupSize: Int? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        onComplete: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(title), code: code, length: length, characters: characters, groupSize: groupSize, description: description,
            message: message, isRequired: isRequired, isOptional: isOptional, onComplete: onComplete)
    }

    /// A code field with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: The label above the cells, which also names the code for VoiceOver.
    ///   - code: The code entered so far, 0 to `length` characters.
    ///   - length: The number of characters, at least 1. The web's default is 6.
    ///   - characters: Digits only (the default), or letters and digits.
    ///   - groupSize: Draw a divider between groups of this many cells.
    ///   - description: Help shown under the cells, such as where the code was sent.
    ///   - message: An error, warning or success message; it also colours the cells' boundaries.
    ///   - isRequired: Marks the label with an asterisk, and tells VoiceOver the field is required.
    ///   - isOptional: Marks the label "(optional)" instead. Ignored when `isRequired` is true.
    ///   - onComplete: Runs with the code each time it becomes complete.
    public init(
        label: Text,
        code: Binding<String>,
        length: Int = 6,
        characters: QeetrixOTPCharacters = .digits,
        groupSize: Int? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        onComplete: (@MainActor (String) -> Void)? = nil
    ) {
        context = QeetrixFieldContext(label: label, description: description, message: message, isRequired: isRequired)
        self.isOptional = isOptional
        self.code = code
        self.length = max(1, length)
        self.characters = characters
        self.groupSize = groupSize
        self.onComplete = onComplete
    }

    /// The cells alone, named "One-time code" for VoiceOver — for a screen whose heading already says what
    /// the code is.
    public init(
        code: Binding<String>,
        length: Int = 6,
        characters: QeetrixOTPCharacters = .digits,
        groupSize: Int? = nil,
        onComplete: (@MainActor (String) -> Void)? = nil
    ) {
        context = nil
        isOptional = false
        self.code = code
        self.length = max(1, length)
        self.characters = characters
        self.groupSize = groupSize
        self.onComplete = onComplete
    }

    public var body: some View {
        let field = QeetrixOTPField(code: code, length: length, characters: characters, groupSize: groupSize, onComplete: onComplete)
        if let context {
            QeetrixFieldLayout(context: context, isOptional: isOptional) { field }
        } else {
            field
        }
    }
}

struct QeetrixOTPField: View {
    let code: Binding<String>
    let length: Int
    let characters: QeetrixOTPCharacters
    let groupSize: Int?
    let onComplete: (@MainActor (String) -> Void)?

    /// The native field's text, kept equal to the code — so what the field holds is always what the cells
    /// show, and deleting never removes an invisible character.
    @State private var text = ""
    @FocusState private var isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context

    var body: some View {
        cells
            .overlay {
                // An empty prompt: without one the field would draw its label as a placeholder over the cells.
                TextField(text: $text, prompt: Text(verbatim: "")) { context?.label ?? QeetrixStrings.oneTimeCode }
                    .qeetrixTextInputTraits(.oneTimeCode(characters))
                    .focused($isFocused)
                    // The cells draw the code; the field itself shows nothing, caret included.
                    .foregroundStyle(.clear)
                    .tint(.clear)
                    .privacySensitive()
                    .qeetrixFieldControlAccessibility(fallbackLabel: QeetrixStrings.oneTimeCode)
            }
            .contentShape(Rectangle())
            .onTapGesture { if isEnabled { isFocused = true } }
            .onAppear { text = code.wrappedValue }
            .onChange(of: text) { _, newText in
                let accepted = QeetrixOTPCode.accept(newText, previous: code.wrappedValue, length: length, characters: characters)
                if accepted != newText { text = accepted }
                guard accepted != code.wrappedValue else { return }
                let wasComplete = code.wrappedValue.count == length
                code.wrappedValue = accepted
                if accepted.count == length && !wasComplete { onComplete?(accepted) }
            }
            .onChange(of: code.wrappedValue) { _, newCode in
                // The app cleared or set the code.
                if newCode != text { text = newCode }
            }
    }

    private var cells: some View {
        let characters = Array(code.wrappedValue)
        let active = min(characters.count, length - 1)
        return HStack(spacing: QeetrixWebScale.spacing(2)) {  // gap-2
            ForEach(0..<length, id: \.self) { index in
                if let groupSize, groupSize > 0, index > 0, index % groupSize == 0 {
                    Capsule()
                        .fill(QeetrixColor.borderStrong)
                        .frame(width: QeetrixWebScale.spacing(2.5), height: QeetrixStroke.hairline)  // h-px w-2.5
                }
                QeetrixOTPCell(
                    character: index < characters.count ? characters[index] : nil,
                    state: QeetrixFieldState(
                        isEnabled: isEnabled, isReadOnly: false, isFocused: isFocused && index == active, isHovered: false,
                        tone: context?.message?.tone),
                    height: QeetrixInputTokens.height(density) + QeetrixWebScale.spacing(4))
            }
        }
        // A code reads left to right in every script; the row still sits at the leading edge.
        .environment(\.layoutDirection, .leftToRight)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityHidden(true)
    }
}

/// One cell: up to 48 pt wide, never below 32, the control height plus 16 pt tall, the character in
/// Fira Code at 18 pt.
private struct QeetrixOTPCell: View {
    let character: Character?
    let state: QeetrixFieldState
    let height: CGFloat

    var body: some View {
        Text(verbatim: character.map(String.init) ?? "")
            .qeetrixType(QeetrixOTPMetrics.characterType)
            .monospacedDigit()  // tabular-nums
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .foregroundStyle(QeetrixInputTokens.foreground)
            .frame(minWidth: QeetrixWebScale.spacing(8), maxWidth: QeetrixWebScale.spacing(12), minHeight: height)  // min-w-8 max-w-12
            .qeetrixFieldSurface(state)
    }
}

enum QeetrixOTPMetrics {
    /// `font-mono text-lg`.
    static let characterType: QeetrixTypeSpec = {
        let code = QeetrixTextRole.code.tokens
        return QeetrixTypeSpec(
            QeetrixTextRoleTokens(
                family: code.family, size: QeetrixWebScale.textLG.size, weight: .regular, lineHeight: QeetrixWebScale.textLG.lineHeight,
                letterSpacing: code.letterSpacing, geometry: code.geometry),
            scalesLike: .title3)
    }()
}

/// The rules for what a code field accepts, separate from the view so they can be tested.
enum QeetrixOTPCode {
    /// The code after an edit: only `characters` (digits from any script entered as 0–9), at most `length`
    /// of them. When the edit brought in a whole code at once — a paste or AutoFill into a part-filled
    /// field — the new code replaces the old, as on the web; otherwise characters past `length` are dropped.
    static func accept(_ text: String, previous: String, length: Int, characters: QeetrixOTPCharacters) -> String {
        let cleaned = normalise(text, characters: characters)
        guard cleaned.count > length else { return cleaned }
        let inserted = cleaned.hasPrefix(previous) ? String(cleaned.dropFirst(previous.count)) : cleaned
        return String((inserted.count >= length ? inserted : cleaned).prefix(length))
    }

    static func normalise(_ text: String, characters: QeetrixOTPCharacters) -> String {
        var result = ""
        for character in text {
            if let digit = decimalDigit(character) {
                result.append(Character(String(digit)))
            } else if characters == .alphanumeric, character.isASCII, character.isLetter {
                result.append(character)
            }
        }
        return result
    }

    /// The value of a decimal digit in any script — 7, ٧, ७ — and nil for anything else, including
    /// numerals that are not decimal digits, such as Ⅶ.
    static func decimalDigit(_ character: Character) -> Int? {
        guard character.unicodeScalars.count == 1, let scalar = character.unicodeScalars.first,
            scalar.properties.numericType == .decimal
        else { return nil }
        return character.wholeNumberValue
    }
}
