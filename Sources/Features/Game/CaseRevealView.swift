import SwiftUI

struct CaseRevealView: View {
    let casePrompt: String

    var body: some View {
        VStack(spacing: 24) {
            Text("The Case")
                .font(PPCTypography.title)
            PPCCard {
                Text(casePrompt)
                    .font(PPCTypography.title)
            }
            NavigationLink("Start Arguments", destination: TimerView(secondsRemaining: 60))
        }
        .padding()
        .background(PPCColors.background)
        .navigationTitle("Case Reveal")
    }
}
