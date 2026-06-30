import SwiftUI

/// The vote. Each eligible voter taps Guilty or Not Guilty; the verdict unlocks
/// only once everyone has weighed in. Votes live in the store so a backgrounded
/// app comes back exactly where it left off.
struct VotingView: View {
    let store: GameStore

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("THE JURY DECIDES")
                    .ppcEyebrow(PPCColors.robe)
                    .padding(.top, 4)

                if let prompt = store.currentCase?.prompt {
                    Text(prompt)
                        .font(.system(.headline, design: .serif))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(PPCColors.ink)
                        .padding(.horizontal, 12)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ForEach(store.voters) { voter in
                    ballot(for: voter)
                }

                tally

                PPCPrimaryButton(title: "Read the Verdict", icon: "gavel.fill", isEnabled: store.allVotesCast) {
                    Haptics.gavel()
                    AnalyticsService.shared.track(.voteCompleted)
                    store.revealVerdict()
                }
                if !store.allVotesCast {
                    Text("Everyone on the jury votes before the gavel falls.")
                        .font(PPCTypography.caption)
                        .foregroundStyle(PPCColors.inkSecondary)
                }
            }
            .padding(20)
        }
    }

    private func ballot(for voter: RoundPlayer) -> some View {
        PPCCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text(voter.emoji).font(.title3)
                    Text(voter.name).font(PPCTypography.headline).foregroundStyle(PPCColors.ink)
                    Spacer()
                    RoleBadge(role: voter.role)
                }
                HStack(spacing: 10) {
                    voteButton(voter: voter, guilty: true, label: "Guilty", tint: PPCColors.guilty)
                    voteButton(voter: voter, guilty: false, label: "Not Guilty", tint: PPCColors.notGuilty)
                }
            }
        }
    }

    private func voteButton(voter: RoundPlayer, guilty: Bool, label: String, tint: Color) -> some View {
        let isSelected = store.votes[voter.id] == guilty
        return Button {
            Haptics.selection()
            AnalyticsService.shared.track(.voteCast)
            store.castVote(playerID: voter.id, guilty: isSelected ? nil : guilty)
        } label: {
            Text(label)
                .font(PPCTypography.bodyEmphasis)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(isSelected ? .white : tint)
                .background(isSelected ? tint : tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(PPCPressStyle())
    }

    private var tally: some View {
        HStack(spacing: 0) {
            tallyColumn(count: store.guiltyVotes, label: "Guilty", tint: PPCColors.guilty)
            Divider().frame(height: 36).overlay(PPCColors.hairline)
            tallyColumn(count: store.notGuiltyVotes, label: "Not Guilty", tint: PPCColors.notGuilty)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(PPCColors.paper.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func tallyColumn(count: Int, label: String, tint: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(tint)
                .contentTransition(.numericText())
            Text(label).font(PPCTypography.label).foregroundStyle(PPCColors.inkSecondary)
        }
        .frame(maxWidth: .infinity)
        .animation(.snappy, value: count)
    }
}
