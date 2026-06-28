import SwiftUI

struct VotingView: View {
    let deck: CaseDeck
    let gameCase: GameCase
    let players: [Player]
    @State private var votes: [UUID: Bool] = [:]

    private var jurors: [Player] {
        let jury = players.filter { $0.role == .jury }
        if !jury.isEmpty { return jury }
        let judge = players.filter { $0.role == .judge }
        return judge.isEmpty ? players : judge
    }

    private var guiltyVotes: Int { votes.values.filter { $0 }.count }
    private var notGuiltyVotes: Int { votes.values.filter { !$0 }.count }
    private var allVotesCast: Bool { votes.count == jurors.count }

    var body: some View {
        List {
            Section("Case") {
                Text(gameCase.prompt)
            }

            Section("Jury Votes") {
                ForEach(jurors) { juror in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(juror.name)
                            .font(PPCTypography.body.weight(.bold))
                        Picker("Vote", selection: voteBinding(for: juror)) {
                            Text("Pending").tag(Int?.none)
                            Text("Guilty").tag(Int?.some(1))
                            Text("Not Guilty").tag(Int?.some(0))
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }

            Section("Tally") {
                Text("Guilty: \(guiltyVotes)")
                Text("Not Guilty: \(notGuiltyVotes)")
            }

            Section {
                NavigationLink(
                    "Read Verdict",
                    destination: VerdictView(deck: deck, gameCase: gameCase, players: players, guiltyVotes: guiltyVotes, notGuiltyVotes: notGuiltyVotes)
                )
                .disabled(!allVotesCast)
            }
        }
        .navigationTitle("Voting")
    }

    private func voteBinding(for juror: Player) -> Binding<Int?> {
        Binding<Int?>(
            get: {
                guard let vote = votes[juror.id] else { return nil }
                return vote ? 1 : 0
            },
            set: { newValue in
                switch newValue {
                case 1: votes[juror.id] = true
                case 0: votes[juror.id] = false
                default: votes[juror.id] = nil
                }
                if votes.count == jurors.count {
                    AnalyticsService.shared.track(.voteCompleted)
                }
            }
        )
    }
}
