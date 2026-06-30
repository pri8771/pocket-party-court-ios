import SwiftUI

/// The case file. Presents the charge and who's arguing which side, then hands
/// off to the argument timer.
struct CaseRevealView: View {
    let store: GameStore
    @State private var appeared = false

    private var gameCase: CaseContent? { store.currentCase }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Text("THE CASE FILE")
                    .ppcEyebrow(PPCColors.robe)
                    .padding(.top, 4)

                if let gameCase {
                    caseFile(gameCase)
                    litigants(gameCase)
                } else {
                    Text("No cases available in this deck.")
                        .foregroundStyle(PPCColors.inkSecondary)
                }

                PPCPrimaryButton(title: "Start Arguments", icon: "megaphone.fill") {
                    AnalyticsService.shared.track(.caseRevealed)
                    store.startArguments()
                }
                .padding(.top, 4)
            }
            .padding(20)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
        }
        .onAppear {
            AnalyticsService.shared.track(.caseDrawn)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { appeared = true }
        }
    }

    private func caseFile(_ gameCase: CaseContent) -> some View {
        PPCCard(padding: 22) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    PPCTag(text: gameCase.category)
                    Spacer()
                    Text("No. \(store.round)-\(store.casesPlayed + 1)")
                        .font(PPCTypography.label)
                        .foregroundStyle(PPCColors.inkSecondary)
                }
                Text("The accused stands charged that they…")
                    .font(PPCTypography.caption)
                    .foregroundStyle(PPCColors.inkSecondary)
                Text(gameCase.prompt)
                    .font(.system(.title2, design: .serif).weight(.semibold))
                    .foregroundStyle(PPCColors.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func litigants(_ gameCase: CaseContent) -> some View {
        VStack(spacing: 12) {
            litigantRow(
                role: .plaintiff,
                name: store.plaintiffName,
                hint: gameCase.plaintiffHint
            )
            litigantRow(
                role: .defendant,
                name: store.defendantName,
                hint: gameCase.defendantHint
            )
        }
    }

    private func litigantRow(role: PlayerRole, name: String, hint: String) -> some View {
        PPCCard {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle().fill(role.tint.opacity(0.16))
                    Text(role.emoji).font(.title2)
                }
                .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(name).font(PPCTypography.headline).foregroundStyle(PPCColors.ink)
                        RoleBadge(role: role)
                    }
                    Text(hint).font(PPCTypography.callout).foregroundStyle(PPCColors.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
    }
}
