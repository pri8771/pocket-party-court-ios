import SwiftUI

struct VotingView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Cast Your Vote")
                .font(PPCTypography.title)
            NavigationLink("Alex Wins", destination: VerdictView(winnerName: "Alex"))
            NavigationLink("Sam Wins", destination: VerdictView(winnerName: "Sam"))
        }
        .padding()
        .navigationTitle("Voting")
    }
}
