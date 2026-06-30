import SwiftData
import SwiftUI

/// The payoff: gavel falls, stamp slams, confetti, and the group gets a
/// shareable card. From here every verdict (guilty / not guilty / hung jury)
/// can loop to the next case, rotate roles for a new round, or end the game.
struct VerdictView: View {
    @Environment(\.modelContext) private var modelContext
    let store: GameStore
    var deckAccent: Color = PPCColors.gavel
    var onExit: () -> Void

    @State private var shareURL: URL?
    @State private var didPersist = false

    private var result: VerdictResult? { store.lastResult }

    var body: some View {
        ZStack {
            if let result {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("THE VERDICT")
                            .ppcEyebrow(PPCColors.robe)
                            .padding(.top, 8)

                        VerdictStamp(verdict: result.verdict, animated: true)
                            .padding(.vertical, 6)

                        if let gameCase = store.currentCase {
                            VerdictCardView(deckTitle: store.deck.title, casePrompt: gameCase.prompt, result: result)
                                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                                .shadow(color: .black.opacity(0.1), radius: 16, y: 8)
                        }

                        Text(result.summary)
                            .font(PPCTypography.callout)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(PPCColors.inkSecondary)
                            .padding(.horizontal, 24)

                        standingsStrip

                        shareButton(result: result)
                        actionButtons
                    }
                    .padding(20)
                    .padding(.bottom, 24)
                }
                ConfettiView()
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            AnalyticsService.shared.track(.verdictGenerated)
            persistIfNeeded()
        }
        .task { shareURL = await renderShareCard() }
    }

    // MARK: Buttons

    private func shareButton(result: VerdictResult) -> some View {
        Group {
            if let shareURL {
                ShareLink(
                    item: shareURL,
                    message: Text(ShareService().verdictCardText(
                        deckTitle: store.deck.title,
                        casePrompt: store.currentCase?.prompt ?? "",
                        result: result
                    )),
                    preview: SharePreview("Pocket Party Court Verdict", image: shareURL)
                ) {
                    Label("Share the Verdict Card", systemImage: "square.and.arrow.up")
                        .font(PPCTypography.bodyEmphasis.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(.white)
                        .background(PPCColors.robe)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .simultaneousGesture(TapGesture().onEnded {
                    AnalyticsService.shared.track(.verdictShared)
                })
            } else {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Preparing share card…").font(PPCTypography.caption).foregroundStyle(PPCColors.inkSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
        }
    }

    private var standingsStrip: some View {
        let standings = store.standings
        return Group {
            if store.casesPlayed > 1 {
                VStack(spacing: 8) {
                    Text("Standings · \(store.casesPlayed) cases")
                        .ppcEyebrow(PPCColors.inkSecondary)
                    HStack(spacing: 10) {
                        ForEach(standings.prefix(4), id: \.player.id) { entry in
                            VStack(spacing: 2) {
                                Text(entry.player.emoji)
                                Text("\(entry.score)")
                                    .font(PPCTypography.bodyEmphasis)
                                    .foregroundStyle(entry.score > 0 ? PPCColors.gavel : PPCColors.inkSecondary)
                            }
                        }
                    }
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(PPCColors.paper.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            PPCPrimaryButton(title: "Next Case", icon: "arrow.right.circle.fill") {
                AnalyticsService.shared.track(.nextCaseStarted)
                reset()
                store.nextCase()
            }
            HStack(spacing: 12) {
                PPCSecondaryButton(title: "Crown Winner", icon: "crown.fill") {
                    AnalyticsService.shared.track(.winnerCrowned)
                    store.crownWinner()
                }
                PPCSecondaryButton(title: "End Game", icon: "flag.checkered") {
                    AnalyticsService.shared.track(.gameExited)
                    onExit()
                }
            }
        }
    }

    // MARK: Persistence (privacy-safe)

    private func persistIfNeeded() {
        guard !didPersist, let snapshot = store.makeCompletedSnapshot() else { return }
        didPersist = true
        let players = snapshot.players.map {
            Player(name: $0.name, emoji: $0.emoji, role: $0.role)
        }
        let session = GameSession(
            completedAt: .now,
            currentRound: store.round,
            totalRounds: store.round,
            selectedDeckTitle: snapshot.deckTitle,
            casePrompt: snapshot.casePrompt,
            guiltyVotes: snapshot.guiltyVotes,
            notGuiltyVotes: snapshot.notGuiltyVotes,
            verdictTitle: snapshot.verdictTitle,
            verdictRawValue: snapshot.verdict.rawValue,
            verdictSummary: snapshot.verdictSummary,
            players: players
        )
        modelContext.insert(session)
        do {
            try modelContext.save()
            AnalyticsService.shared.track(.sessionSaved)
        } catch {
            // History is a nicety, not the game — a failed save must never block
            // the room. Drop the unsaved insert and carry on.
            modelContext.delete(session)
        }
    }

    private func reset() {
        shareURL = nil
        didPersist = false
    }

    // MARK: Share card rendering

    @MainActor
    private func renderShareCard() async -> URL? {
        guard let result, let gameCase = store.currentCase else { return nil }
        let renderer = ImageRenderer(
            content: VerdictCardView(deckTitle: store.deck.title, casePrompt: gameCase.prompt, result: result)
                .padding(16)
                .background(PPCColors.background)
        )
        renderer.scale = 3

        #if canImport(UIKit)
        guard let image = renderer.uiImage, let data = image.pngData() else { return nil }
        #else
        guard let cg = renderer.cgImage else { return nil }
        let bitmap = NSBitmapImageRep(cgImage: cg)
        guard let data = bitmap.representation(using: .png, properties: [:]) else { return nil }
        #endif

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("pocket-party-court-verdict-\(UUID().uuidString).png")
        try? data.write(to: url)
        return url
    }
}
