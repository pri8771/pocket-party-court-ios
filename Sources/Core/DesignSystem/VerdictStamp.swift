import SwiftUI

/// A rubber-stamp rendering of the verdict — double-ruled border, tinted ink,
/// jaunty rotation. Used both on the live verdict screen (with a slam-in
/// animation) and baked flat onto the shareable card.
struct VerdictStamp: View {
    let verdict: Verdict
    var animated: Bool = false

    @State private var slammed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let shown = animated ? slammed : true
        HStack(spacing: 10) {
            Text(verdict.emoji)
                .font(.system(size: 30))
            Text(verdict.stampText)
                .font(.system(size: 34, weight: .heavy, design: .serif))
                .kerning(1)
                .fixedSize()
        }
        .foregroundStyle(verdict.tint)
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(verdict.tint, lineWidth: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .strokeBorder(verdict.tint.opacity(0.55), lineWidth: 1.5)
                .padding(4)
        )
        .rotationEffect(.degrees(-8))
        .opacity(shown ? 1 : 0)
        .scaleEffect(shown ? 1 : (reduceMotion ? 1 : 2.2))
        .onAppear {
            guard animated, !reduceMotion else { slammed = true; return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                slammed = true
            }
            Haptics.gavel()
        }
    }
}

#Preview {
    VStack(spacing: 28) {
        VerdictStamp(verdict: .guilty)
        VerdictStamp(verdict: .notGuilty)
        VerdictStamp(verdict: .hungJury)
    }
    .padding(40)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ppcScreenBackground()
}
