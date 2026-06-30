import SwiftUI

/// The shared app backdrop: warm parchment with a faint, repeating "⚖" motif
/// watermark so screens feel like courtroom stationery rather than a blank page.
/// Honors Reduce Transparency by dropping the watermark.
struct PPCBackground: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        ZStack {
            PPCColors.background
            if !reduceTransparency {
                GeometryReader { geo in
                    let spacing: CGFloat = 84
                    let cols = Int(geo.size.width / spacing) + 2
                    let rows = Int(geo.size.height / spacing) + 2
                    ForEach(0..<rows, id: \.self) { r in
                        ForEach(0..<cols, id: \.self) { c in
                            Text("⚖")
                                .font(.system(size: 26))
                                .foregroundStyle(PPCColors.robe.opacity(0.035))
                                .rotationEffect(.degrees((r + c).isMultiple(of: 2) ? -12 : 12))
                                .position(
                                    x: CGFloat(c) * spacing + (r.isMultiple(of: 2) ? spacing / 2 : 0),
                                    y: CGFloat(r) * spacing
                                )
                        }
                    }
                }
                .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
    }
}

/// Convenience modifier to drop the parchment backdrop behind any screen.
extension View {
    func ppcScreenBackground() -> some View {
        background(PPCBackground())
    }
}
