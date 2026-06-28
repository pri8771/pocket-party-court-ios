import SwiftUI

struct GameSetupView: View {
    @State private var playerOne = "Alex"
    @State private var playerTwo = "Sam"

    var body: some View {
        Form {
            Section("Players") {
                TextField("Player 1", text: $playerOne)
                TextField("Player 2", text: $playerTwo)
            }
            NavigationLink("Reveal First Case", destination: CaseRevealView(casePrompt: "Ate the last slice of pizza and claimed it was evidence."))
        }
        .navigationTitle("Game Setup")
    }
}
