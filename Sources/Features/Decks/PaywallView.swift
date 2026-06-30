import SwiftUI

/// One-time purchase flow for a premium deck pack. No subscriptions, no ads —
/// the free game stays fully playable; packs are pure upside.
struct PaywallView: View {
    @Environment(StoreService.self) private var store
    @Environment(\.dismiss) private var dismiss
    let deck: CaseDeck

    @State private var isPurchasing = false
    @State private var purchased = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                ZStack {
                    Circle().fill(deck.accent.opacity(0.16)).frame(width: 110, height: 110)
                    Text(deck.icon).font(.system(size: 56))
                }
                .padding(.top, 12)

                VStack(spacing: 8) {
                    Text(deck.title).font(PPCTypography.hero).foregroundStyle(PPCColors.ink)
                    Text(deck.deckDescription)
                        .font(PPCTypography.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(PPCColors.inkSecondary)
                }

                VStack(spacing: 14) {
                    benefit(icon: "infinity", text: "\(deck.cases.count) fresh cases — unlock once, keep forever")
                    benefit(icon: "nosign", text: "No subscription, no ads, ever")
                    benefit(icon: "iphone", text: "Plays fully offline, like the rest of the game")
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(PPCColors.paper)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(PPCColors.hairline))

                if purchased {
                    Label("Unlocked! Enjoy the new cases.", systemImage: "checkmark.seal.fill")
                        .font(PPCTypography.bodyEmphasis)
                        .foregroundStyle(PPCColors.notGuilty)
                } else {
                    PPCPrimaryButton(
                        title: isPurchasing ? "Unlocking…" : "Unlock for \(store.displayPrice)",
                        icon: "lock.open.fill",
                        isEnabled: !isPurchasing
                    ) {
                        Task { await purchase() }
                    }
                    Button("Restore purchases") {
                        Task { await store.restorePurchases() }
                    }
                    .font(PPCTypography.caption)
                    .foregroundStyle(PPCColors.robe)
                }

                Text("Pricing shown is illustrative until App Store pricing loads.")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(PPCColors.inkSecondary)
            }
            .padding(24)
        }
        .ppcScreenBackground()
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(PPCColors.inkSecondary)
            }
            .padding(16)
        }
        .onAppear { AnalyticsService.shared.track(.paywallViewed) }
    }

    private func benefit(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.headline).foregroundStyle(deck.accent).frame(width: 26)
            Text(text).font(PPCTypography.callout).foregroundStyle(PPCColors.ink)
            Spacer(minLength: 0)
        }
    }

    private func purchase() async {
        isPurchasing = true
        let ok = await store.purchase(productID: deck.productID)
        isPurchasing = false
        if ok {
            purchased = true
            AnalyticsService.shared.track(.deckUnlocked)
            Haptics.success()
            try? await Task.sleep(nanoseconds: 800_000_000)
            dismiss()
        }
    }
}
