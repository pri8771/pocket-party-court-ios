import SwiftUI

struct TimerView: View {
    @State var secondsRemaining: Int

    var body: some View {
        VStack(spacing: 24) {
            Text("Argument Timer")
                .font(PPCTypography.title)
            Text("\(secondsRemaining)s")
                .font(.system(size: 72, weight: .black, design: .rounded))
            NavigationLink("Proceed to Vote", destination: VotingView())
        }
        .padding()
        .navigationTitle("Arguments")
    }
}
