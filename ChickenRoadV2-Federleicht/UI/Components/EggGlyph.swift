import SwiftUI

struct EggShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        p.move(to: CGPoint(x: w * 0.5, y: 0))
        p.addCurve(
            to: CGPoint(x: w, y: h * 0.62),
            control1: CGPoint(x: w * 0.95, y: h * 0.05),
            control2: CGPoint(x: w, y: h * 0.30)
        )
        p.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w, y: h * 0.92),
            control2: CGPoint(x: w * 0.80, y: h)
        )
        p.addCurve(
            to: CGPoint(x: 0, y: h * 0.62),
            control1: CGPoint(x: w * 0.20, y: h),
            control2: CGPoint(x: 0, y: h * 0.92)
        )
        p.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0, y: h * 0.30),
            control2: CGPoint(x: w * 0.05, y: h * 0.05)
        )
        return p
    }
}

struct EggGlyph: View {
    var size: CGFloat = 22
    var color: Color = AppColor.streakGold
    var withShine: Bool = true

    var body: some View {
        ZStack {
            EggShape()
                .fill(color)
                .overlay(
                    EggShape()
                        .stroke(color.opacity(0.5), lineWidth: 0.5)
                )
                .frame(width: size * 0.78, height: size)
            if withShine {
                Ellipse()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: size * 0.16, height: size * 0.22)
                    .offset(x: -size * 0.14, y: -size * 0.20)
            }
        }
        .frame(width: size, height: size)
    }
}
