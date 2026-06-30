import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StoreService.self) private var store
    @Query(sort: \CaseDeck.sortIndex) private var decks: [CaseDeck]

    @State private var viewModel = HomeViewModel()
    @State private var seedingError: String?
    @State private var path: [CaseDeck] = []
    @State private var paywallDeck: CaseDeck?
    @State private var showAbout = false

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 22) {
                    header
                    if let seedingError { errorCard(seedingError) }
                    deckSection
                    footerLinks
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
            .ppcScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { PPCWordmark(compact: true) }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAbout = true } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("About Pocket Party Court")
                }
            }
            .navigationDestination(for: CaseDeck.self) { deck in
                GameSetupView(deck: deck)
            }
            .sheet(item: $paywallDeck) { deck in
                PaywallView(deck: deck)
            }
            .sheet(isPresented: $showAbout) { AboutView() }
            .task { seedIfNeeded() }
        }
    }

    // MARK: Sections

    private var header: some View {
        VStack(spacing: 14) {
            GavelMark(size: 92)
                .padding(.top, 8)
            VStack(spacing: 8) {
                Text(viewModel.headline)
                    .font(PPCTypography.hero)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(PPCColors.ink)
                Text(viewModel.subtitle)
                    .font(PPCTypography.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(PPCColors.inkSecondary)
                    .padding(.horizontal, 8)
            }
        }
        .padding(.top, 4)
    }

    private var deckSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            PPCSectionHeader(eyebrow: "Pick your court", title: "Choose a deck")
            if decks.isEmpty && seedingError == nil {
                loadingCard
            } else {
                ForEach(decks) { deck in
                    Button {
                        select(deck)
                    } label: {
                        DeckCard(deck: deck, locked: isLocked(deck))
                    }
                    .buttonStyle(PPCPressStyle())
                }
            }
        }
    }

    private var footerLinks: some View {
        VStack(spacing: 12) {
            NavigationLink {
                DeckListView()
            } label: {
                homeLinkRow(icon: "rectangle.stack.fill", title: "Browse all cases",
                            subtitle: "Peek at every prompt before you play")
            }
            NavigationLink {
                HistoryView()
            } label: {
                homeLinkRow(icon: "clock.arrow.circlepath", title: "Verdict history",
                            subtitle: "Revisit past trials, kept on this device")
            }
        }
        .padding(.top, 4)
    }

    private func homeLinkRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(PPCColors.robe)
                .frame(width: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(PPCTypography.bodyEmphasis).foregroundStyle(PPCColors.ink)
                Text(subtitle).font(PPCTypography.caption).foregroundStyle(PPCColors.inkSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.footnote).foregroundStyle(PPCColors.inkSecondary)
        }
        .padding(16)
        .background(PPCColors.paper.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(PPCColors.hairline, lineWidth: 1)
        )
        .contentShape(Rectangle())
    }

    private var loadingCard: some View {
        PPCCard {
            HStack(spacing: 12) {
                ProgressView()
                Text("Shuffling the starter decks…")
                    .font(PPCTypography.callout)
                    .foregroundStyle(PPCColors.inkSecondary)
            }
        }
    }

    private func errorCard(_ message: String) -> some View {
        PPCCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Deck loading issue", systemImage: "exclamationmark.triangle.fill")
                    .font(PPCTypography.headline)
                    .foregroundStyle(PPCColors.guilty)
                Text(message)
                    .font(PPCTypography.callout)
                    .foregroundStyle(PPCColors.inkSecondary)
                Button("Try again") { seedingError = nil; seedIfNeeded() }
                    .font(PPCTypography.caption)
                    .foregroundStyle(PPCColors.gavel)
            }
        }
    }

    // MARK: Actions

    private func isLocked(_ deck: CaseDeck) -> Bool { !store.isUnlocked(deck) }

    private func select(_ deck: CaseDeck) {
        if isLocked(deck) {
            paywallDeck = deck
        } else {
            Haptics.selection()
            path.append(deck)
        }
    }

    private func seedIfNeeded() {
        do {
            try DeckService().seedStarterDecksIfNeeded(in: modelContext)
        } catch {
            seedingError = "Starter decks could not be loaded: \(error.localizedDescription)"
        }
    }
}

#Preview {
    HomeView()
        .environment(StoreService.shared)
        .modelContainer(for: [CaseDeck.self, GameCase.self, GameSession.self, Player.self], inMemory: true)
}
