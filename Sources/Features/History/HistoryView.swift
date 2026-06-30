import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<GameSession> { $0.completedAt != nil },
           sort: \GameSession.completedAt, order: .reverse)
    private var completedSessions: [GameSession]

    var body: some View {
        Group {
            if completedSessions.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 14) {
                        Text("Saved on this device only. Nothing is uploaded.")
                            .font(PPCTypography.caption)
                            .foregroundStyle(PPCColors.inkSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(completedSessions) { session in
                            row(session)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .ppcScreenBackground()
        .navigationTitle("Verdict History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { AnalyticsService.shared.track(.historyViewed) }
    }

    private func row(_ session: GameSession) -> some View {
        let tint = session.verdict?.tint ?? PPCColors.robe
        return PPCCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(session.selectedDeckTitle)
                        .font(PPCTypography.headline)
                        .foregroundStyle(PPCColors.ink)
                    Spacer()
                    Text(session.verdict?.title ?? session.verdictTitle)
                        .font(PPCTypography.label)
                        .foregroundStyle(tint)
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(tint.opacity(0.14))
                        .clipShape(Capsule())
                }
                Text(session.casePrompt)
                    .font(.system(.callout, design: .serif))
                    .foregroundStyle(PPCColors.inkSecondary)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    Text((session.completedAt ?? session.createdAt).formatted(date: .abbreviated, time: .shortened))
                    Text("•")
                    Text("^[\(session.players.count) player](inflect: true)")
                }
                .font(PPCTypography.caption)
                .foregroundStyle(PPCColors.inkSecondary)
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                modelContext.delete(session)
                try? modelContext.save()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            GavelMark(size: 72)
            Text("No verdicts yet")
                .font(PPCTypography.title)
                .foregroundStyle(PPCColors.ink)
            Text("Finish a case and the verdict lands here — kept private on your device.")
                .font(PPCTypography.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(PPCColors.inkSecondary)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack { HistoryView() }
        .modelContainer(for: [CaseDeck.self, GameCase.self, GameSession.self, Player.self], inMemory: true)
}
