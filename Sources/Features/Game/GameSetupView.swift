import SwiftUI

struct GameSetupView: View {
    let deck: CaseDeck
    @State private var playerNames = ["Alex", "Sam", "Jordan"]
    @State private var selectedCase: GameCase?
    @State private var argumentDuration = 60

    private var trimmedNames: [String] {
        playerNames.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }

    private var validationMessage: String? {
        let names = trimmedNames
        guard (2...6).contains(names.count) else { return "Enter 2–6 player names." }
        guard Set(names.map { $0.lowercased() }).count == names.count else { return "Player names must be unique." }
        return nil
    }

    private var assignedPlayers: [Player] {
        let names = trimmedNames
        return names.enumerated().map { index, name in
            let role: PlayerRole
            switch (names.count, index) {
            case (2, 0): role = .plaintiff
            case (2, 1): role = .defendant
            case (_, 0): role = .judge
            case (_, 1): role = .plaintiff
            case (_, 2): role = .defendant
            default: role = .jury
            }
            return Player(name: name, role: role)
        }
    }

    var body: some View {
        Form {
            Section("Deck") {
                Text("\(deck.icon) \(deck.title)")
                Text(deck.deckDescription)
                    .foregroundStyle(.secondary)
            }

            Section("Players") {
                ForEach(playerNames.indices, id: \.self) { index in
                    HStack {
                        TextField("Player \(index + 1)", text: $playerNames[index])
                        Text(roleName(for: index))
                            .font(PPCTypography.caption)
                            .foregroundStyle(PPCColors.gavel)
                    }
                }
                .onDelete { playerNames.remove(atOffsets: $0) }

                if playerNames.count < 6 {
                    Button("Add Player") { playerNames.append("") }
                }
            } footer: {
                Text("Roles are assigned by order for 3+ players: judge, plaintiff, defendant, then jury. With two players, players are plaintiff and defendant and both vote locally.")
            }

            Section("Timer") {
                Stepper("Argument timer: \(argumentDuration) seconds", value: $argumentDuration, in: 30...180, step: 15)
            }

            if let validationMessage {
                Section {
                    Text(validationMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("Reveal First Case") {
                    selectedCase = deck.cases.randomElement() ?? deck.cases.first
                }
                .disabled(validationMessage != nil || deck.cases.isEmpty)
            }
        }
        .navigationTitle("Game Setup")
        .navigationDestination(item: $selectedCase) { gameCase in
            CaseRevealView(deck: deck, gameCase: gameCase, players: assignedPlayers, argumentDuration: argumentDuration)
        }
    }

    private func roleName(for index: Int) -> String {
        switch (trimmedNames.count, index) {
        case (2, 0): return PlayerRole.plaintiff.rawValue
        case (2, 1): return PlayerRole.defendant.rawValue
        case (_, 0): return PlayerRole.judge.rawValue
        case (_, 1): return PlayerRole.plaintiff.rawValue
        case (_, 2): return PlayerRole.defendant.rawValue
        default: return PlayerRole.jury.rawValue
        }
    }
}
