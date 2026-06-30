import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(v) (\(b))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        GavelMark(size: 88).padding(.top, 8)
                        PPCWordmark()
                        Text(appVersion)
                            .font(PPCTypography.caption)
                            .foregroundStyle(PPCColors.inkSecondary)
                    }

                    PPCCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("What is this?").font(PPCTypography.headline).foregroundStyle(PPCColors.ink)
                            Text("Pocket Party Court turns your group's silliest disputes into a five-minute mock trial. Pick a case, argue your side, let the jury vote, and share the verdict card. One phone, no setup, no winners' tears (mostly).")
                                .font(PPCTypography.callout)
                                .foregroundStyle(PPCColors.inkSecondary)
                        }
                    }

                    PPCCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your privacy").font(PPCTypography.headline).foregroundStyle(PPCColors.ink)
                            privacyRow(icon: "wifi.slash", text: "Plays fully offline. No account, no login.")
                            privacyRow(icon: "lock.shield", text: "Everything stays on your device — nothing is uploaded.")
                            privacyRow(icon: "hand.raised", text: "Verdict cards never include who voted which way.")
                        }
                    }

                    ShareLink(item: shareText) {
                        Label("Tell a friend", systemImage: "square.and.arrow.up")
                            .font(PPCTypography.bodyEmphasis)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .foregroundStyle(.white)
                            .background(PPCColors.gavel)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    Text("Made for living rooms, dorms, and dinner tables.")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(PPCColors.inkSecondary)
                }
                .padding(24)
            }
            .ppcScreenBackground()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear { AnalyticsService.shared.track(.aboutViewed) }
        }
    }

    private var shareText: String {
        "Put your friends on trial with Pocket Party Court — a 5-minute offline party game. ⚖️"
    }

    private func privacyRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.callout).foregroundStyle(PPCColors.robe).frame(width: 24)
            Text(text).font(PPCTypography.callout).foregroundStyle(PPCColors.inkSecondary)
            Spacer(minLength: 0)
        }
    }
}

#Preview { AboutView() }
