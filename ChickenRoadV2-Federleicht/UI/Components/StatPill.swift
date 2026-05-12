import SwiftUI

struct StatPill: View {
    let titleKey: LocalizedStringKey
    let value: String
    var systemIcon: String? = nil
    var accent: Color = AppColor.streakGold

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                if let systemIcon {
                    if systemIcon.contains(".") {
                        Image(systemName: systemIcon)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(accent)
                    } else {
                        Text(systemIcon)
                            .font(.system(size: 14))
                    }
                }
                Text(titleKey)
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColor.navyText.opacity(0.6))
            }
            Text(value)
                .font(AppFont.numeric(24))
                .foregroundStyle(AppColor.navyText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: AppColor.navyText.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}
