import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                PPCColors.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("⚖️ Pocket Party Court")
                        .font(PPCTypography.hero)
                        .multilineTextAlignment(.center)
                    Text(viewModel.subtitle)
                        .font(PPCTypography.body)
                        .multilineTextAlignment(.center)
                    NavigationLink("Start a Case", destination: GameSetupView())
                        .buttonStyle(.borderedProminent)
                    NavigationLink("Browse Decks", destination: DeckListView())
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
