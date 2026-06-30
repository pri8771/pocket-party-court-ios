import SwiftUI

/// The shareable verdict card — designed to be screenshot-perfect and to *be*
/// the ad. Carries only the case, the verdict stamp, and the winner. By design
/// it never shows the vote breakdown or anything said in the room.
struct VerdictCardView: View {
    let deckTitle: String
    let casePrompt: String
    let result: VerdictResult

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                PPCWordmark(compact: true)
                Spacer()
                Text(deckTitle.uppercased())
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .kerning(1)
                    .foregroundStyle(PPCColors.inkSecondary)
            }

            Divider().overlay(PPCColors.hairline)

            VStack(spacing: 6) {
                Text("THE CHARGE")
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .kerning(1.5)
                    .foregroundStyle(PPCColors.gavel)
                Text(casePrompt)
                    .font(.system(.title3, design: .serif).weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(PPCColors.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 4)

            VerdictStamp(verdict: result.verdict)
                .padding(.vertical, 8)

            VStack(spacing: 2) {
                Text("IN FAVOR OF")
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .kerning(1.5)
                    .foregroundStyle(PPCColors.inkSecondary)
                Text(result.winnerName)
                    .font(.system(.title2, design: .rounded).weight(.heavy))
                    .foregroundStyle(result.verdict.tint)
            }

            Text(ShareService.tagline)
                .font(.system(.caption, design: .rounded).weight(.medium))
                .foregroundStyle(PPCColors.inkSecondary)
                .padding(.top, 2)
        }
        .padding(28)
        .frame(width: 360)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(PPCColors.paper)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(result.verdict.tint.opacity(0.25), lineWidth: 2)
                )
        )
    }
}

#Preview {
    VerdictCardView(
        deckTitle: "Friend Court",
        casePrompt: "Ate the last slice of pizza and left the box as a decoy.",
        result: VerdictEngine.result(guiltyVotes: 3, notGuiltyVotes: 1, plaintiffName: "Sam", defendantName: "Alex")
    )
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ppcScreenBackground()
}
