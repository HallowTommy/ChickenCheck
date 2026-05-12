import SwiftUI

struct PathStep: View {
    let task: CareTask
    let isLast: Bool
    var onTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onTap) {
                ZStack {
                    Circle()
                        .fill(haloColor)
                        .frame(width: 84, height: 84)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .shadow(color: AppColor.navyText.opacity(0.12), radius: 8, x: 0, y: 4)
                    if task.kind == .eggs {
                        EggGlyph(size: 32, color: iconColor)
                    } else {
                        Image(systemName: task.kind.systemIcon)
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(iconColor)
                    }
                }
            }
            .buttonStyle(BouncyPressStyle())
            VStack(spacing: 4) {
                Text(LocalizedStringKey(task.kind.labelKey))
                    .font(AppFont.body(15, weight: .heavy))
                    .foregroundStyle(AppColor.navyText)
                BadgeView(status: task.status)
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .trailing) {
            if !isLast {
                connectorLine
                    .frame(height: 4)
                    .offset(x: 16, y: -42)
            }
        }
    }

    private var connectorLine: some View {
        ZStack {
            Capsule()
                .fill(AppColor.navyText.opacity(0.12))
                .frame(height: 4)
            HStack(spacing: 6) {
                ForEach(0..<6) { _ in
                    Capsule()
                        .fill(AppColor.roadYellow)
                        .frame(width: 8, height: 4)
                }
            }
        }
    }

    private var iconColor: Color {
        switch task.kind {
        case .feed: return AppColor.warmOrange
        case .water: return AppColor.skyBlue
        case .eggs: return AppColor.streakGold
        case .clean: return AppColor.grassGreen
        case .health: return AppColor.redAlert
        }
    }

    private var haloColor: Color {
        switch task.status {
        case .completed: return AppColor.grassGreen.opacity(0.35)
        case .current: return AppColor.roadYellow.opacity(0.55)
        case .missed: return AppColor.redAlert.opacity(0.35)
        case .upcoming: return AppColor.cream
        }
    }
}
