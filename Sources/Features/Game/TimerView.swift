import SwiftUI

struct TimerView: View {
    let deck: CaseDeck
    let gameCase: GameCase
    let players: [Player]
    let duration: Int
    @State private var secondsRemaining: Int
    @State private var shouldAdvance = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(deck: CaseDeck, gameCase: GameCase, players: [Player], duration: Int = 60) {
        self.deck = deck
        self.gameCase = gameCase
        self.players = players
        self.duration = duration
        _secondsRemaining = State(initialValue: duration)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Argument Timer")
                .font(PPCTypography.title)
            Text("\(secondsRemaining)s")
                .font(.system(size: 72, weight: .black, design: .rounded))
            Text(gameCase.prompt)
                .font(PPCTypography.body)
                .multilineTextAlignment(.center)
            Button("Proceed to Vote") { shouldAdvance = true }
                .buttonStyle(.borderedProminent)
            NavigationLink("", destination: VotingView(deck: deck, gameCase: gameCase, players: players), isActive: $shouldAdvance)
                .hidden()
        }
        .padding()
        .navigationTitle("Arguments")
        .onReceive(timer) { _ in
            guard secondsRemaining > 0, !shouldAdvance else { return }
            secondsRemaining -= 1
            if secondsRemaining == 0 { shouldAdvance = true }
        }
    }
}
