import SwiftUI

/// The argument phase: a shared countdown while the plaintiff and defendant make
/// their cases. Host-friendly controls — pause, add time, or skip straight to
/// the vote — keep the room in control of the pace.
struct ArgumentTimerView: View {
    let store: GameStore

    @State private var secondsRemaining: Int = 0
    @State private var isRunning = true
    @State private var didStart = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 24) {
            Text("ARGUMENTS")
                .ppcEyebrow(PPCColors.robe)

            HStack(spacing: 22) {
                speakerChip(role: .plaintiff, name: store.plaintiffName)
                Text("vs").font(PPCTypography.caption).foregroundStyle(PPCColors.inkSecondary)
                speakerChip(role: .defendant, name: store.defendantName)
            }

            CountdownRing(secondsRemaining: secondsRemaining, total: max(store.argumentDuration, 1))

            if let prompt = store.currentCase?.prompt {
                Text(prompt)
                    .font(.system(.headline, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(PPCColors.ink)
                    .padding(.horizontal, 28)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            controls
        }
        .padding(.vertical, 8)
        .padding(.bottom, 16)
        .onAppear {
            if !didStart {
                secondsRemaining = store.argumentDuration
                didStart = true
            }
        }
        .onReceive(ticker) { _ in tick() }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    Haptics.tap()
                    isRunning.toggle()
                } label: {
                    Label(isRunning ? "Pause" : "Resume",
                          systemImage: isRunning ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(PPCColors.paper)
                        .foregroundStyle(PPCColors.robe)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(PPCColors.hairline))
                }
                .buttonStyle(PPCPressStyle())

                Button {
                    Haptics.tap()
                    secondsRemaining += 30
                } label: {
                    Label("+30s", systemImage: "goforward.30")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(PPCColors.paper)
                        .foregroundStyle(PPCColors.robe)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(PPCColors.hairline))
                }
                .buttonStyle(PPCPressStyle())
            }
            .font(PPCTypography.bodyEmphasis)

            PPCPrimaryButton(title: "Send to the Jury", icon: "checklist") {
                advance()
            }
        }
        .padding(.horizontal, 20)
    }

    private func speakerChip(role: PlayerRole, name: String) -> some View {
        VStack(spacing: 6) {
            Text(role.emoji).font(.title)
            Text(name).font(PPCTypography.caption).foregroundStyle(PPCColors.ink)
            RoleBadge(role: role)
        }
    }

    private func tick() {
        guard isRunning, secondsRemaining > 0 else { return }
        secondsRemaining -= 1
        if secondsRemaining == 0 {
            Haptics.warning()
            advance()
        }
    }

    private func advance() {
        guard store.phase == .arguments else { return }
        AnalyticsService.shared.track(.timerCompleted)
        store.goToVoting()
    }
}
