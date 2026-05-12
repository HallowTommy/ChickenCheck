import SwiftUI

struct FarmDecoration: View {
    var showFence: Bool = false
    var showFlowers: Bool = true
    var showSun: Bool = true

    var body: some View {
        ZStack {
            if showSun {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(AppColor.streakGold)
                    .opacity(0.92)
                    .padding(.top, 14)
                    .padding(.trailing, 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                Image(systemName: "cloud.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, 16)
                    .padding(.leading, 22)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                Image(systemName: "cloud.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.top, 50)
                    .padding(.leading, 110)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            GrassStrip(showFlowers: showFlowers)
                .frame(height: 36)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .allowsHitTesting(false)
    }
}

private struct GrassStrip: View {
    let showFlowers: Bool

    var body: some View {
        ZStack(alignment: .top) {
            GrassShape()
                .fill(
                    LinearGradient(
                        colors: [AppColor.grassGreen.opacity(0.85), AppColor.grassGreen],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            if showFlowers {
                GeometryReader { geo in
                    let positions: [(x: CGFloat, size: CGFloat)] = [
                        (0.10, 12), (0.24, 14), (0.42, 11),
                        (0.62, 13), (0.78, 12), (0.90, 14)
                    ]
                    ForEach(0..<positions.count, id: \.self) { idx in
                        let p = positions[idx]
                        Daisy(size: p.size)
                            .position(x: geo.size.width * p.x, y: 6)
                    }
                }
            }
        }
    }
}

private struct GrassShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: 12))
        var x: CGFloat = 0
        let step: CGFloat = 18
        var up = true
        while x < rect.width {
            let nextX = min(x + step, rect.width)
            let midX = (x + nextX) / 2
            p.addQuadCurve(to: CGPoint(x: nextX, y: 12), control: CGPoint(x: midX, y: up ? 0 : 14))
            up.toggle()
            x = nextX
        }
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.closeSubpath()
        return p
    }
}

private struct Daisy: View {
    var size: CGFloat = 12

    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Capsule()
                    .fill(.white)
                    .frame(width: size * 0.32, height: size * 0.78)
                    .offset(y: -size * 0.22)
                    .rotationEffect(.degrees(Double(i) * 72))
            }
            Circle()
                .fill(AppColor.streakGold)
                .frame(width: size * 0.36, height: size * 0.36)
        }
        .frame(width: size, height: size)
        .shadow(color: AppColor.navyText.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}
