import SwiftUI

struct BadgeView: View {
    let status: CareStatus

    var body: some View {
        Text(LocalizedStringKey(status.badgeKey))
            .font(AppFont.caption(12))
            .foregroundStyle(status.badgeForeground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(status.badgeFill)
            )
    }
}
