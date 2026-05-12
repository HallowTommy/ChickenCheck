import SwiftUI

struct TaskCard: View {
    let task: CareTask
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconBackground)
                        .frame(width: 48, height: 48)
                    if task.kind == .eggs {
                        EggGlyph(size: 26, color: iconColor)
                    } else {
                        Image(systemName: task.kind.systemIcon)
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundStyle(iconColor)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey(task.kind.labelKey))
                        .font(AppFont.body(17, weight: .heavy))
                        .foregroundStyle(AppColor.navyText)
                    Text(LocalizedStringKey(task.kind.subtitleKey))
                        .font(AppFont.caption(13))
                        .foregroundStyle(AppColor.navyText.opacity(0.55))
                }
                Spacer()
                BadgeView(status: task.status)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: AppColor.navyText.opacity(0.06), radius: 10, x: 0, y: 6)
            )
        }
        .buttonStyle(BouncyPressStyle())
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

    private var iconBackground: Color {
        iconColor.opacity(0.16)
    }
}
