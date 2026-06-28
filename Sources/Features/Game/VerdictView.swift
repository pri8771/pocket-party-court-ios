import SwiftUI

struct VerdictView: View {
    let winnerName: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Verdict")
                .font(PPCTypography.hero)
            Text("\(winnerName) wins the case!")
                .font(PPCTypography.title)
            ShareLink(item: "Pocket Party Court verdict: \(winnerName) wins!") {
                Label("Share Verdict Card", systemImage: "square.and.arrow.up")
            }
        }
        .padding()
        .navigationTitle("Verdict")
    }
}
