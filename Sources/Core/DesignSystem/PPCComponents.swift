import SwiftUI

// MARK: - Buttons

/// The primary call-to-action. Gavel-orange, full width, with a press spring.
struct PPCPrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 10) {
                if let icon { Image(systemName: icon) }
                Text(title)
            }
            .font(PPCTypography.bodyEmphasis.weight(.bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .foregroundStyle(.white)
            .background(PPCColors.gavelGradient)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: PPCColors.gavel.opacity(0.35), radius: 14, y: 8)
            .opacity(isEnabled ? 1 : 0.45)
        }
        .buttonStyle(PPCPressStyle())
        .disabled(!isEnabled)
    }
}

/// Secondary / quieter action. Plum outline on paper.
struct PPCSecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon) }
                Text(title)
            }
            .font(PPCTypography.bodyEmphasis)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(PPCColors.robe)
            .background(PPCColors.paper)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(PPCColors.robe.opacity(0.25), lineWidth: 1.5)
            )
        }
        .buttonStyle(PPCPressStyle())
    }
}

/// Subtle scale-down on press, shared by all custom buttons.
struct PPCPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Surfaces

/// Standard paper card with a soft shadow and hairline edge.
struct PPCCard<Content: View>: View {
    var padding: CGFloat = 18
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(PPCColors.paper)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(PPCColors.hairline, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 14, y: 8)
    }
}

// MARK: - Tags & badges

/// A small rounded pill used for categories and metadata.
struct PPCTag: View {
    let text: String
    var tint: Color = PPCColors.gavel

    var body: some View {
        Text(text)
            .font(PPCTypography.label)
            .textCase(.uppercase)
            .kerning(0.8)
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tint.opacity(0.14))
            .clipShape(Capsule())
    }
}

/// Colored role badge for the courtroom roles.
struct RoleBadge: View {
    let role: PlayerRole

    var body: some View {
        HStack(spacing: 4) {
            Text(role.emoji)
            Text(role.rawValue)
        }
        .font(PPCTypography.label)
        .foregroundStyle(role.tint)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(role.tint.opacity(0.14))
        .clipShape(Capsule())
    }
}

// MARK: - Section header

struct PPCSectionHeader: View {
    let eyebrow: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(eyebrow).ppcEyebrow()
            Text(title).font(PPCTypography.title)
                .foregroundStyle(PPCColors.ink)
        }
    }
}
