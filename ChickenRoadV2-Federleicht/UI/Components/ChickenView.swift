import SwiftUI

struct ChickenView: View {
    let pose: ChickenPose
    let accessory: Accessory
    var size: CGFloat = 180
    var isFloating: Bool = true

    @State private var bob: CGFloat = 0

    var body: some View {
        ZStack {
            chickenSprite
            if let overlay = accessory.assetName, UIImage(named: overlay) != nil {
                Image(overlay)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * accessoryScale, height: size * accessoryScale)
                    .offset(x: size * accessoryOffset.x, y: size * accessoryOffset.y)
            }
        }
        .frame(width: size, height: size)
        .compositingGroup()
        .offset(y: bob)
        .onAppear {
            guard isFloating else { return }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                bob = -6
            }
        }
    }

    private var accessoryScale: CGFloat {
        switch accessory {
        case .none: return 0
        case .bow: return 0.28
        case .hat: return 0.50
        case .glasses: return 0.46
        }
    }

    private var accessoryOffset: CGPoint {
        let base: CGPoint = {
            switch accessory {
            case .none: return .zero
            case .bow: return CGPoint(x: 0.18, y: -0.22)
            case .hat: return CGPoint(x: 0, y: -0.20)
            case .glasses: return CGPoint(x: 0, y: -0.05)
            }
        }()
        let poseShift: CGFloat = pose == .happy ? -0.06 : 0
        return CGPoint(x: base.x, y: base.y + poseShift)
    }

    @ViewBuilder
    private var chickenSprite: some View {
        if UIImage(named: pose.assetName) != nil {
            Image(pose.assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            FallbackChicken(pose: pose, size: size)
        }
    }
}

private struct FallbackChicken: View {
    let pose: ChickenPose
    let size: CGFloat

    var body: some View {
        ZStack {
            body_oval
            wattle
            comb
            eyes
            beak
            wing
            feet
            poseDecor
        }
        .frame(width: size, height: size)
    }

    private var body_oval: some View {
        Ellipse()
            .fill(Color.white)
            .overlay(
                Ellipse().stroke(AppColor.navyText.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: AppColor.navyText.opacity(0.08), radius: 10, x: 0, y: 6)
            .frame(width: size * 0.82, height: size * 0.78)
            .offset(y: size * 0.04)
    }

    private var comb: some View {
        HStack(spacing: size * 0.012) {
            Circle().fill(AppColor.redAlert).frame(width: size * 0.085, height: size * 0.085)
            Circle().fill(AppColor.redAlert).frame(width: size * 0.105, height: size * 0.105)
            Circle().fill(AppColor.redAlert).frame(width: size * 0.085, height: size * 0.085)
        }
        .offset(y: -size * 0.34)
    }

    private var wattle: some View {
        Capsule()
            .fill(AppColor.redAlert.opacity(0.85))
            .frame(width: size * 0.05, height: size * 0.08)
            .offset(y: size * 0.04)
    }

    private var eyes: some View {
        HStack(spacing: size * 0.18) {
            ChickenEye(pose: pose, size: size)
            ChickenEye(pose: pose, size: size)
        }
        .offset(y: -size * 0.16)
    }

    private var beak: some View {
        Triangle()
            .fill(AppColor.warmOrange)
            .frame(width: size * 0.11, height: size * 0.08)
            .rotationEffect(.degrees(180))
            .offset(y: -size * 0.04)
    }

    private var wing: some View {
        Capsule()
            .fill(Color.white)
            .overlay(
                Capsule().stroke(AppColor.navyText.opacity(0.12), lineWidth: 1)
            )
            .frame(width: size * 0.26, height: size * 0.16)
            .rotationEffect(.degrees(-12))
            .offset(x: -size * 0.18, y: size * 0.08)
    }

    private var feet: some View {
        HStack(spacing: size * 0.18) {
            FootShape().fill(AppColor.warmOrange).frame(width: size * 0.08, height: size * 0.08)
            FootShape().fill(AppColor.warmOrange).frame(width: size * 0.08, height: size * 0.08)
        }
        .offset(y: size * 0.42)
    }

    @ViewBuilder
    private var poseDecor: some View {
        switch pose {
        case .happy:
            Image(systemName: "sparkle")
                .font(.system(size: size * 0.12))
                .foregroundStyle(AppColor.streakGold)
                .offset(x: size * 0.32, y: -size * 0.28)
        case .eating:
            Circle()
                .fill(AppColor.warmOrange)
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(y: size * 0.36)
        case .drinking:
            Image(systemName: "drop.fill")
                .font(.system(size: size * 0.12))
                .foregroundStyle(AppColor.skyBlue)
                .offset(y: size * 0.36)
        case .layingEgg:
            Ellipse()
                .fill(AppColor.streakGold.opacity(0.9))
                .frame(width: size * 0.13, height: size * 0.16)
                .offset(x: size * 0.28, y: size * 0.32)
        case .sleeping:
            Text("Z")
                .font(.system(size: size * 0.16, weight: .heavy, design: .rounded))
                .foregroundStyle(AppColor.skyBlue)
                .offset(x: size * 0.28, y: -size * 0.28)
        case .sad:
            Image(systemName: "cloud.rain.fill")
                .font(.system(size: size * 0.12))
                .foregroundStyle(AppColor.navyText.opacity(0.5))
                .offset(x: size * 0.28, y: -size * 0.28)
        default:
            EmptyView()
        }
    }
}

private struct ChickenEye: View {
    let pose: ChickenPose
    let size: CGFloat

    var body: some View {
        ZStack {
            if pose == .sleeping {
                Capsule()
                    .fill(AppColor.navyText)
                    .frame(width: size * 0.06, height: size * 0.012)
            } else {
                Circle()
                    .fill(AppColor.navyText)
                    .frame(width: size * 0.06, height: size * 0.06)
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.022, height: size * 0.022)
                    .offset(x: size * 0.013, y: -size * 0.013)
            }
        }
    }
}

private struct FootShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY * 0.6))
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY * 0.6))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY * 0.6))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY * 0.6))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return p.strokedPath(.init(lineWidth: rect.width * 0.18, lineCap: .round))
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
