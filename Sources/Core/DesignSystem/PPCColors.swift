import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Pocket Party Court color system.
///
/// A warm "playful courtroom" palette: parchment paper, deep judicial plum,
/// and a gavel-orange accent. Every token is dynamic so the app reads well in
/// light and dark mode. Colors are defined in code (no asset-catalog color
/// sets) to keep the design system self-contained and reviewable in one place.
enum PPCColors {
    // MARK: Brand

    /// Warm parchment app background.
    static let background = dynamic(light: 0xFBF4E4, dark: 0x141019)
    /// Slightly raised surface used behind grouped content.
    static let surface = dynamic(light: 0xFFFDF7, dark: 0x201826)
    /// Card / paper surface.
    static let paper = dynamic(light: 0xFFFFFF, dark: 0x271E30)
    /// Hairline separators and card strokes.
    static let hairline = dynamic(light: 0xE7DCC4, dark: 0x3A2F46)

    /// Primary ink for body text.
    static let ink = dynamic(light: 0x1E1525, dark: 0xF4ECFB)
    /// Secondary text.
    static let inkSecondary = dynamic(light: 0x6C5E78, dark: 0xB7A9C6)

    /// Deep judicial plum — the "robe" color, used for headers and the brand mark.
    static let robe = dynamic(light: 0x47286E, dark: 0xC9A8F0)
    /// Gavel orange — the primary action / energy accent.
    static let gavel = dynamic(light: 0xF0782C, dark: 0xFF9A4D)
    /// Soft gold used for stamps and flourishes.
    static let brass = dynamic(light: 0xE0A92E, dark: 0xF2C44B)

    // MARK: Verdict semantics

    static let guilty = dynamic(light: 0xD64545, dark: 0xF06A6A)
    static let notGuilty = dynamic(light: 0x2E9E6B, dark: 0x4FD49A)
    static let hung = dynamic(light: 0x8A7CCB, dark: 0xA99CF0)

    // MARK: Gradients

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [dynamic(light: 0x5A2E86, dark: 0x3A2152),
                     dynamic(light: 0x7A3F9E, dark: 0x4E2A6E)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var gavelGradient: LinearGradient {
        LinearGradient(
            colors: [dynamic(light: 0xF7913A, dark: 0xFF9A4D),
                     dynamic(light: 0xEC6A2C, dark: 0xF07A33)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: Helpers

    /// Builds a color that adapts to light/dark from two hex values.
    static func dynamic(light: UInt32, dark: UInt32) -> Color {
        #if canImport(UIKit)
        return Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
        #else
        return Color(hex: light)
        #endif
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: 1.0
        )
    }
}

#if canImport(UIKit)
extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}
#endif
