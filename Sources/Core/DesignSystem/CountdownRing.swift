import SwiftUI

/// A circular countdown used on the argument timer. Shows remaining time as a
/// shrinking ring plus a big numeric readout; the ring shifts toward the gavel
/// color and then red as time runs low.
struct CountdownRing: View {
    let secondsRemaining: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return max(0, min(1, Double(secondsRemaining) / Double(total)))
    }

    private var ringColor: Color {
        if secondsRemaining <= 5 { return PPCColors.guilty }
        if secondsRemaining <= 15 { return PPCColors.gavel }
        return PPCColors.robe
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(PPCColors.hairline, lineWidth: 16)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.9), value: secondsRemaining)

            VStack(spacing: 0) {
                Text("\(secondsRemaining)")
                    .font(.system(size: 76, weight: .heavy, design: .rounded))
                    .foregroundStyle(PPCColors.ink)
                    .contentTransition(.numericText(countsDown: true))
                    .monospacedDigit()
                Text("seconds")
                    .ppcEyebrow(PPCColors.inkSecondary)
            }
        }
        .frame(width: 240, height: 240)
        .animation(.snappy, value: ringColor)
    }
}

#Preview {
    CountdownRing(secondsRemaining: 12, total: 60)
        .padding()
        .ppcScreenBackground()
}
