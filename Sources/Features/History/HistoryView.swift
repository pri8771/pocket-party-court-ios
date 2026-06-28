import SwiftData
import SwiftUI

struct HistoryView: View {
    @Query(filter: #Predicate<GameSession> { $0.completedAt != nil }, sort: \GameSession.completedAt, order: .reverse)
    private var completedSessions: [GameSession]

    var body: some View {
        List {
            if completedSessions.isEmpty {
                ContentUnavailableView("No completed sessions", systemImage: "clock.arrow.circlepath", description: Text("Finish a case to see verdict history here."))
            } else {
                ForEach(completedSessions) { session in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(session.selectedDeckTitle)
                                .font(PPCTypography.title)
                            Spacer()
                            Text(session.verdictTitle)
                                .font(PPCTypography.caption.weight(.bold))
                                .foregroundStyle(PPCColors.gavel)
                        }
                        Text(session.casePrompt)
                            .font(PPCTypography.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        Text(session.completedAt ?? session.createdAt, style: .date)
                            .font(PPCTypography.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("History")
        .onAppear {
            AnalyticsService.shared.track(.historyViewed)
        }
    }
}

#Preview {
    NavigationStack { HistoryView() }
}
