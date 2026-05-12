import SwiftUI

struct SkyBackdrop: View {
    var showSun: Bool = true
    var showClouds: Bool = true
    var showHills: Bool = true

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.62, green: 0.85, blue: 0.99), location: 0.0),
                    .init(color: Color(red: 0.78, green: 0.92, blue: 1.0), location: 0.55),
                    .init(color: AppColor.cream, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            if showHills {
                HillsLayer()
                    .fill(AppColor.grassGreen.opacity(0.30))
                    .frame(maxHeight: .infinity, alignment: .bottom)
                HillsLayer(offset: 0.55)
                    .fill(AppColor.grassGreen.opacity(0.45))
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }

            if showSun {
                SunWithRays()
                    .frame(width: 80, height: 80)
                    .padding(.top, 10)
                    .padding(.trailing, 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }

            if showClouds {
                Cloud()
                    .fill(.white.opacity(0.92))
                    .frame(width: 90, height: 36)
                    .padding(.top, 28)
                    .padding(.leading, 22)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                Cloud()
                    .fill(.white.opacity(0.7))
                    .frame(width: 60, height: 24)
                    .padding(.top, 70)
                    .padding(.leading, 130)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                Cloud()
                    .fill(.white.opacity(0.85))
                    .frame(width: 70, height: 28)
                    .padding(.top, 90)
                    .padding(.trailing, 28)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct Cloud: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let h = rect.height
        let w = rect.width
        let baseY = h * 0.75
        p.move(to: CGPoint(x: w * 0.10, y: baseY))
        p.addArc(center: CGPoint(x: w * 0.20, y: h * 0.55), radius: h * 0.30, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
        p.addArc(center: CGPoint(x: w * 0.42, y: h * 0.40), radius: h * 0.42, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
        p.addArc(center: CGPoint(x: w * 0.65, y: h * 0.45), radius: h * 0.38, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
        p.addArc(center: CGPoint(x: w * 0.85, y: h * 0.58), radius: h * 0.28, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
        p.addLine(to: CGPoint(x: w * 0.10, y: baseY))
        p.closeSubpath()
        return p
    }
}

private struct SunWithRays: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Capsule()
                    .fill(AppColor.streakGold.opacity(0.85))
                    .frame(width: 5, height: 14)
                    .offset(y: -32)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 1.0, green: 0.93, blue: 0.55), AppColor.streakGold],
                        center: .center,
                        startRadius: 4,
                        endRadius: 28
                    )
                )
                .frame(width: 46, height: 46)
                .shadow(color: AppColor.streakGold.opacity(0.55), radius: 14, x: 0, y: 0)
            Group {
                Capsule().fill(AppColor.navyText).frame(width: 4, height: 4).offset(x: -7, y: -2)
                Capsule().fill(AppColor.navyText).frame(width: 4, height: 4).offset(x: 7, y: -2)
                Capsule()
                    .fill(AppColor.navyText)
                    .frame(width: 10, height: 4)
                    .clipShape(Rectangle().offset(y: 2))
                    .offset(y: 6)
            }
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

private struct HillsLayer: Shape {
    var offset: CGFloat = 0.30

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let h = rect.height
        let w = rect.width
        let topY = h * (1 - offset)
        p.move(to: CGPoint(x: 0, y: h))
        p.addLine(to: CGPoint(x: 0, y: topY))
        p.addQuadCurve(to: CGPoint(x: w * 0.35, y: topY - h * 0.08), control: CGPoint(x: w * 0.18, y: topY - h * 0.20))
        p.addQuadCurve(to: CGPoint(x: w * 0.70, y: topY - h * 0.04), control: CGPoint(x: w * 0.55, y: topY - h * 0.18))
        p.addQuadCurve(to: CGPoint(x: w, y: topY - h * 0.06), control: CGPoint(x: w * 0.85, y: topY - h * 0.16))
        p.addLine(to: CGPoint(x: w, y: h))
        p.closeSubpath()
        return p
    }
}
