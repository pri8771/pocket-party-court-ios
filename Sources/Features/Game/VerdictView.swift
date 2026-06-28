import SwiftData
import SwiftUI

struct VerdictCardView: View {
    let deckTitle: String
    let casePrompt: String
    let result: VerdictResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⚖️ Pocket Party Court")
                .font(.system(size: 28, weight: .black, design: .rounded))
            Text(result.title)
                .font(.system(size: 44, weight: .black, design: .rounded))
            Text(casePrompt)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            Text("Guilty \(result.guiltyVotes) • Not Guilty \(result.notGuiltyVotes)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
            Text(result.summary)
                .font(.system(size: 17, design: .rounded))
        }
        .padding(28)
        .frame(width: 600, alignment: .leading)
        .background(PPCColors.paper)
    }
}

struct VerdictView: View {
    @Environment(\.modelContext) private var modelContext
    let deck: CaseDeck
    let gameCase: GameCase
    let players: [Player]
    let guiltyVotes: Int
    let notGuiltyVotes: Int

    @State private var shareURL: URL?
    @State private var didSaveSession = false

    private var plaintiffName: String { players.first(where: { $0.role == .plaintiff })?.name ?? "Plaintiff" }
    private var defendantName: String { players.first(where: { $0.role == .defendant })?.name ?? "Defendant" }
    private var result: VerdictResult {
        GameService().verdict(guiltyVotes: guiltyVotes, notGuiltyVotes: notGuiltyVotes, plaintiffName: plaintiffName, defendantName: defendantName)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Verdict")
                    .font(PPCTypography.hero)
                VerdictCardView(deckTitle: deck.title, casePrompt: gameCase.prompt, result: result)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
                    .padding(.horizontal)
                Text("Winner: \(result.winnerName)")
                    .font(PPCTypography.title)
                if let shareURL {
                    ShareLink(item: shareURL) {
                        Label("Share Verdict Card", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    ProgressView("Preparing share card…")
                }
            }
            .padding()
        }
        .navigationTitle("Verdict")
        .onAppear {
            AnalyticsService.shared.track(.verdictGenerated)
        }
        .task {
            if !didSaveSession {
                saveCompletedSession()
                didSaveSession = true
            }
            shareURL = renderShareCard()
        }
    }

    private func saveCompletedSession() {
        let sessionPlayers = players.map { player in
            Player(name: player.name, emoji: player.emoji, score: player.score, role: player.role)
        }
        let session = GameSession(
            completedAt: .now,
            selectedDeckTitle: deck.title,
            casePrompt: gameCase.prompt,
            guiltyVotes: guiltyVotes,
            notGuiltyVotes: notGuiltyVotes,
            verdictTitle: result.title,
            verdictSummary: result.summary,
            players: sessionPlayers
        )
        modelContext.insert(session)
        try? modelContext.save()
        AnalyticsService.shared.track(.sessionSaved)
    }

    @MainActor
    private func renderShareCard() -> URL? {
        let renderer = ImageRenderer(content: VerdictCardView(deckTitle: deck.title, casePrompt: gameCase.prompt, result: result))
        renderer.scale = 2

        #if canImport(UIKit)
        guard let image = renderer.uiImage,
              let data = image.pngData() else { return nil }
        #else
        guard let image = renderer.cgImage else { return nil }
        let bitmap = NSBitmapImageRep(cgImage: image)
        guard let data = bitmap.representation(using: .png, properties: [:]) else { return nil }
        #endif

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("pocket-party-court-verdict-\(UUID().uuidString).png")
        try? data.write(to: url)
        return url
    }
}
