import SwiftUI

/// The app's brand mark: a gavel resting on its sound block, drawn as a vector
/// so it scales crisply anywhere (home hero, share card, empty states). Pure
/// SwiftUI shapes — no bitmap assets.
struct GavelMark: View {
    var size: CGFloat = 64
    var tint: Color = PPCColors.gavel

    var body: some View {
        ZStack {
            // Sound block (base)
            Capsule()
                .fill(PPCColors.robe)
                .frame(width: size * 0.78, height: size * 0.16)
                .offset(y: size * 0.40)

            // Gavel: head + handle, rotated for a "mid-bang" feel.
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.06, style: .continuous)
                    .fill(tint)
                    .frame(width: size * 0.46, height: size * 0.26)
                Capsule()
                    .fill(PPCColors.brass)
                    .frame(width: size * 0.12, height: size * 0.16)
                    .offset(x: size * 0.27)
                Capsule()
                    .fill(PPCColors.brass)
                    .frame(width: size * 0.12, height: size * 0.16)
                    .offset(x: -size * 0.27)
                Capsule()
                    .fill(tint)
                    .frame(width: size * 0.12, height: size * 0.52)
                    .offset(y: size * 0.30)
            }
            .rotationEffect(.degrees(-18), anchor: .bottom)
            .offset(x: size * 0.04, y: -size * 0.08)
        }
        .frame(width: size, height: size)
    }
}

/// Horizontal lockup of the gavel mark + wordmark for headers and cards.
struct PPCWordmark: View {
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            GavelMark(size: compact ? 28 : 40)
            VStack(alignment: .leading, spacing: -2) {
                Text("Pocket Party")
                    .font(.system(.headline, design: .serif).weight(.bold))
                Text("COURT")
                    .font(.system(.subheadline, design: .serif).weight(.heavy))
                    .kerning(3)
                    .foregroundStyle(PPCColors.gavel)
            }
            .foregroundStyle(PPCColors.robe)
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        GavelMark(size: 120)
        PPCWordmark()
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ppcScreenBackground()
}
