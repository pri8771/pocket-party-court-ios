import SwiftUI

/// Rich deck card used on Home and the deck browser. Shows the deck's accent,
/// icon, blurb, case count, and a work-safe / premium-lock badge.
struct DeckCard: View {
    let deck: CaseDeck
    var locked: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            // Accent icon chip
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(deck.accent.opacity(0.16))
                Text(deck.icon)
                    .font(.system(size: 30))
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(deck.title)
                        .font(PPCTypography.title3)
                        .foregroundStyle(PPCColors.ink)
                    if deck.isPremium {
                        Image(systemName: locked ? "lock.fill" : "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(locked ? PPCColors.brass : PPCColors.notGuilty)
                    }
                }
                Text(deck.deckDescription)
                    .font(PPCTypography.callout)
                    .foregroundStyle(PPCColors.inkSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    PPCTag(text: "\(deck.cases.count) cases", tint: deck.accent)
                    if deck.isWorkSafe {
                        PPCTag(text: "Work-safe", tint: PPCColors.notGuilty)
                    }
                    if deck.isPremium && locked {
                        PPCTag(text: "Premium", tint: PPCColors.brass)
                    }
                }
            }

            Spacer(minLength: 0)

            Image(systemName: locked ? "lock.circle.fill" : "chevron.right.circle.fill")
                .font(.title3)
                .foregroundStyle(locked ? PPCColors.brass : deck.accent.opacity(0.6))
        }
        .padding(14)
        .background(PPCColors.paper)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(deck.accent.opacity(0.18), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
        .contentShape(Rectangle())
    }
}
