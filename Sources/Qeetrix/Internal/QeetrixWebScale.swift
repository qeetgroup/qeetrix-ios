import CoreGraphics

/// The Tailwind CSS default-theme values qeetrix-ui components use through utility classes — `h-7`,
/// `px-2.5`, `text-sm`, `leading-snug` — rather than through Qeetrix tokens.
///
/// They are not Qeetrix tokens, so the generator does not read them: they are restated here, once,
/// from `tailwindcss` 4.3.3 `theme.css` (the version in qeetrix-ui's `bun.lock` at the pinned commit
/// `7d7f651`). Component code writes the web class beside each use, for example
/// `QeetrixWebScale.spacing(2.5)  // px-2.5`. ADR 0011 records why, and the upstream discrepancy.
enum QeetrixWebScale {
    /// `--spacing: 0.25rem` — one step of the spacing scale, in points (1 rem = 16 pt).
    static let spacingStep: CGFloat = 4

    /// A spacing-scale value: `spacing(2.5)` is `p-2.5`, `h-7` is `spacing(7)`.
    static func spacing(_ steps: CGFloat) -> CGFloat {
        steps * spacingStep
    }

    /// A step of Tailwind's type ramp: a size and its paired line height, as a multiple of the size.
    struct TextStep: Hashable, Sendable {
        let size: CGFloat
        let lineHeight: Double
    }

    /// `--text-xs: 0.75rem`, `--text-xs--line-height: calc(1 / 0.75)`.
    static let textXS = TextStep(size: 12, lineHeight: 1 / 0.75)
    /// `--text-sm: 0.875rem`, `--text-sm--line-height: calc(1.25 / 0.875)`.
    static let textSM = TextStep(size: 14, lineHeight: 1.25 / 0.875)
    /// `--text-base: 1rem`, `--text-base--line-height: calc(1.5 / 1)`.
    static let textBase = TextStep(size: 16, lineHeight: 1.5)
    /// `--text-lg: 1.125rem`, `--text-lg--line-height: calc(1.75 / 1.125)`.
    static let textLG = TextStep(size: 18, lineHeight: 1.75 / 1.125)
    /// `--text-xl: 1.25rem`, `--text-xl--line-height: calc(1.75 / 1.25)`.
    static let textXL = TextStep(size: 20, lineHeight: 1.75 / 1.25)
    /// `--text-2xl: 1.5rem`, `--text-2xl--line-height: calc(2 / 1.5)`.
    static let text2XL = TextStep(size: 24, lineHeight: 2 / 1.5)

    /// `--leading-snug: 1.375`.
    static let leadingSnug: Double = 1.375
    /// `--leading-relaxed: 1.625`.
    static let leadingRelaxed: Double = 1.625

    /// `--animate-spin: spin 1s linear infinite` — one turn of `animate-spin`, in seconds.
    static let spinDuration: Double = 1
}
