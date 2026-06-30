import SwiftUI

/// Pocket Party Court type scale.
///
/// Two voices: a friendly **rounded** family for most UI (approachable, party
/// energy) and a **serif** family reserved for "official court" moments — the
/// verdict title and the brand mark — so the courtroom flavor reads without
/// making the whole app feel stuffy. All sizes are relative to Dynamic Type.
enum PPCTypography {
    /// Big playful display, e.g. the home hero.
    static let hero = Font.system(.largeTitle, design: .rounded).weight(.heavy)
    /// "Official" serif display for verdicts and the wordmark.
    static let courtDisplay = Font.system(.largeTitle, design: .serif).weight(.bold)
    static let title = Font.system(.title2, design: .rounded).weight(.bold)
    static let title3 = Font.system(.title3, design: .rounded).weight(.semibold)
    static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let body = Font.system(.body, design: .rounded)
    static let bodyEmphasis = Font.system(.body, design: .rounded).weight(.semibold)
    static let callout = Font.system(.callout, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded).weight(.semibold)
    /// Spaced, uppercased label voice for tags and section eyebrows.
    static let label = Font.system(.caption2, design: .rounded).weight(.bold)
}

extension View {
    /// Applies an uppercased, letter-spaced "eyebrow" label style.
    func ppcEyebrow(_ color: Color = PPCColors.gavel) -> some View {
        self
            .font(PPCTypography.label)
            .textCase(.uppercase)
            .kerning(1.2)
            .foregroundStyle(color)
    }
}
