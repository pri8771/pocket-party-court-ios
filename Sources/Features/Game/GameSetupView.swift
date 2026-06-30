import SwiftUI

struct GameSetupView: View {
    let deck: CaseDeck

    @State private var playerNames: [String] = ["Alex", "Sam", "Jordan"]
    @State private var argumentDuration = 60
    @State private var activeStore: GameStore?

    private static let emojiPalette = ["⚖️", "🦊", "🐼", "🐯", "🦁", "🐸", "🐙", "🦄"]

    private var trimmedNames: [String] {
        playerNames.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }

    private var validationMessage: String? {
        let names = trimmedNames
        guard (JuryRules.minPlayers...JuryRules.maxPlayers).contains(names.count) else {
            return "Enter \(JuryRules.minPlayers)–\(JuryRules.maxPlayers) player names."
        }
        guard Set(names.map { $0.lowercased() }).count == names.count else {
            return "Player names must be unique."
        }
        return nil
    }

    private var canStart: Bool { validationMessage == nil && !deck.cases.isEmpty }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                deckBanner
                playersCard
                timerCard
                if let validationMessage {
                    Label(validationMessage, systemImage: "exclamationmark.circle.fill")
                        .font(PPCTypography.caption)
                        .foregroundStyle(PPCColors.guilty)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                PPCPrimaryButton(title: "Begin Trial", icon: "gavel.fill", isEnabled: canStart) {
                    startGame()
                }
                Text("Roles are assigned by order. The plaintiff and defendant argue; the judge and jury vote. With two players, both argue and vote.")
                    .font(PPCTypography.caption)
                    .foregroundStyle(PPCColors.inkSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(20)
        }
        .ppcScreenBackground()
        .navigationTitle("Set the Stage")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $activeStore) { store in
            GameContainerView(store: store, deckAccent: deck.accent)
        }
    }

    // MARK: Cards

    private var deckBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(deck.accent.opacity(0.16))
                Text(deck.icon).font(.system(size: 30))
            }
            .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 3) {
                Text(deck.title).font(PPCTypography.title3).foregroundStyle(PPCColors.ink)
                Text("\(deck.cases.count) cases ready").font(PPCTypography.caption).foregroundStyle(PPCColors.inkSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(PPCColors.paper)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(PPCColors.hairline, lineWidth: 1))
    }

    private var playersCard: some View {
        PPCCard {
            VStack(alignment: .leading, spacing: 14) {
                PPCSectionHeader(eyebrow: "Who's in the room", title: "Players")
                ForEach(playerNames.indices, id: \.self) { index in
                    HStack(spacing: 10) {
                        Text(Self.emojiPalette[index % Self.emojiPalette.count])
                            .font(.title3)
                        TextField("Player \(index + 1)", text: $playerNames[index])
                            .textInputAutocapitalization(.words)
                            .font(PPCTypography.body)
                        RoleBadge(role: JuryRules.role(forIndex: index, playerCount: trimmedNames.count))
                        if playerNames.count > JuryRules.minPlayers {
                            Button {
                                Haptics.tap()
                                playerNames.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill").foregroundStyle(PPCColors.inkSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    if index < playerNames.count - 1 { Divider().overlay(PPCColors.hairline) }
                }
                if playerNames.count < JuryRules.maxPlayers {
                    Button {
                        Haptics.tap()
                        playerNames.append("")
                    } label: {
                        Label("Add player", systemImage: "plus.circle.fill")
                            .font(PPCTypography.bodyEmphasis)
                            .foregroundStyle(PPCColors.gavel)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var timerCard: some View {
        PPCCard {
            VStack(alignment: .leading, spacing: 12) {
                PPCSectionHeader(eyebrow: "Keep it moving", title: "Argument timer")
                Stepper(value: $argumentDuration, in: 30...180, step: 15) {
                    HStack {
                        Image(systemName: "timer").foregroundStyle(PPCColors.gavel)
                        Text("\(argumentDuration) seconds").font(PPCTypography.bodyEmphasis)
                    }
                }
            }
        }
    }

    // MARK: Actions

    private func startGame() {
        let names = trimmedNames
        guard canStart else { return }
        let roundPlayers = names.enumerated().map { index, name in
            RoundPlayer(name: name, emoji: Self.emojiPalette[index % Self.emojiPalette.count])
        }
        let store = GameStore(
            deck: deck.content,
            cases: deck.caseContents,
            players: roundPlayers,
            argumentDuration: argumentDuration
        )
        AnalyticsService.shared.track(.deckSelected)
        AnalyticsService.shared.track(.gameStarted)
        activeStore = store
    }
}

// Allow presenting via `.fullScreenCover(item:)`.
extension GameStore: Identifiable {
    var id: ObjectIdentifier { ObjectIdentifier(self) }
}
