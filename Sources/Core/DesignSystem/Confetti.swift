import SwiftUI

/// A lightweight, self-contained confetti burst used on the verdict reveal.
/// Pure SwiftUI (no UIKit emitter) so it works in previews and the share flow.
/// Respects Reduce Motion by rendering nothing.
struct ConfettiView: View {
    var pieceCount: Int = 70
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    private let colors: [Color] = [
        PPCColors.gavel, PPCColors.brass, PPCColors.robe,
        PPCColors.notGuilty, PPCColors.hung
    ]

    var body: some View {
        GeometryReader { geo in
            if !reduceMotion {
                ZStack {
                    ForEach(0..<pieceCount, id: \.self) { i in
                        ConfettiPiece(
                            color: colors[i % colors.count],
                            startX: deterministicX(i, width: geo.size.width),
                            delay: Double(i % 12) * 0.04,
                            travel: geo.size.height + 80,
                            isAnimating: isAnimating
                        )
                    }
                }
                .onAppear { isAnimating = true }
            }
        }
        .allowsHitTesting(false)
    }

    // Deterministic spread (Math.random is unavailable; derive from index).
    private func deterministicX(_ i: Int, width: CGFloat) -> CGFloat {
        let fraction = (CGFloat((i * 2654435761) % 1000)) / 1000.0
        return fraction * width
    }
}

private struct ConfettiPiece: View {
    let color: Color
    let startX: CGFloat
    let delay: Double
    let travel: CGFloat
    let isAnimating: Bool

    @State private var fall = false

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 8, height: 12)
            .rotationEffect(.degrees(fall ? 320 : 0))
            .position(x: startX, y: fall ? travel : -40)
            .opacity(fall ? 0 : 1)
            .onChange(of: isAnimating) { _, newValue in
                guard newValue else { return }
                withAnimation(.easeIn(duration: 2.4).delay(delay)) {
                    fall = true
                }
            }
            .onAppear {
                if isAnimating {
                    withAnimation(.easeIn(duration: 2.4).delay(delay)) { fall = true }
                }
            }
    }
}
