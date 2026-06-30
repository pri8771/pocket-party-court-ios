import SwiftUI

/// Hosts a single game and renders the screen for the current `GamePhase`.
/// This is the visible surface of the state machine: every transition the
/// `GameStore` makes swaps the content here, so "what do we do next" is always
/// one obvious screen.
struct GameContainerView: View {
    let store: GameStore
    var deckAccent: Color = PPCColors.gavel

    @Environment(\.dismiss) private var dismiss
    @State private var showExitConfirm = false
    @State private var showManagePlayers = false

    var body: some View {
        ZStack {
            PPCBackground()
            LinearGradient(
                colors: [deckAccent.opacity(0.10), .clear],
                startPoint: .top, endPoint: .center
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .animation(.snappy(duration: 0.32), value: store.phase)
        .onAppear { if store.phase == .setup { store.beginCase() } }
        .confirmationDialog("End this trial?", isPresented: $showExitConfirm, titleVisibility: .visible) {
            Button("End trial", role: .destructive) {
                AnalyticsService.shared.track(.gameExited)
                dismiss()
            }
            Button("Keep playing", role: .cancel) {}
        } message: {
            Text("You'll return to the deck. Verdicts you've already read are saved to history.")
        }
        .sheet(isPresented: $showManagePlayers) {
            ManagePlayersSheet(store: store)
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack {
            Button { showExitConfirm = true } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(PPCColors.inkSecondary)
            }
            .accessibilityLabel("End trial")

            Spacer()

            VStack(spacing: 1) {
                Text("Round \(store.round)").font(PPCTypography.caption).foregroundStyle(PPCColors.ink)
                Text(store.deck.title).font(PPCTypography.label).foregroundStyle(PPCColors.inkSecondary)
            }

            Spacer()

            Button { showManagePlayers = true } label: {
                Image(systemName: "person.2.fill")
                    .font(.title3)
                    .foregroundStyle(PPCColors.robe)
            }
            .accessibilityLabel("Manage players")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: Phase content

    @ViewBuilder
    private var content: some View {
        switch store.phase {
        case .setup, .caseReveal:
            CaseRevealView(store: store)
                .transition(.move(edge: .trailing).combined(with: .opacity))
        case .arguments:
            ArgumentTimerView(store: store)
                .transition(.move(edge: .trailing).combined(with: .opacity))
        case .voting:
            VotingView(store: store)
                .transition(.move(edge: .trailing).combined(with: .opacity))
        case .verdict:
            VerdictView(store: store, deckAccent: deckAccent, onExit: { dismiss() })
                .transition(.scale(scale: 0.96).combined(with: .opacity))
        }
    }
}

/// In-game roster editing: add a latecomer or drop someone without ending the
/// round. The store reassigns roles safely if a litigant leaves.
struct ManagePlayersSheet: View {
    let store: GameStore
    @Environment(\.dismiss) private var dismiss
    @State private var newName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Players can come and go — the trial keeps running. New arrivals join the jury.")
                        .font(PPCTypography.caption)
                        .foregroundStyle(PPCColors.inkSecondary)

                    ForEach(store.players) { player in
                        HStack(spacing: 10) {
                            Text(player.emoji).font(.title3)
                            Text(player.name).font(PPCTypography.bodyEmphasis).foregroundStyle(PPCColors.ink)
                            Spacer()
                            RoleBadge(role: player.role)
                            if store.players.count > JuryRules.minPlayers {
                                Button {
                                    Haptics.tap()
                                    store.removePlayer(id: player.id)
                                } label: {
                                    Image(systemName: "minus.circle.fill").foregroundStyle(PPCColors.guilty)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(12)
                        .background(PPCColors.paper)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    if store.players.count < JuryRules.maxPlayers {
                        HStack {
                            TextField("Add a latecomer…", text: $newName)
                                .textInputAutocapitalization(.words)
                                .onSubmit(addPlayer)
                            Button("Add", action: addPlayer)
                                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .padding(12)
                        .background(PPCColors.paper)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding(20)
            }
            .ppcScreenBackground()
            .navigationTitle("Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func addPlayer() {
        let name = newName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        store.addPlayer(name: name)
        newName = ""
        Haptics.success()
    }
}
