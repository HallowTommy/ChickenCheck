import SwiftUI

struct EmptyHint: View {
    let titleKey: LocalizedStringKey
    var subtitleKey: LocalizedStringKey? = nil
    var actionTitleKey: LocalizedStringKey? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(AppColor.skyBlue.opacity(0.25))
                    .frame(width: 140, height: 140)
                ChickenView(pose: .idle, accessory: .none, size: 110, isFloating: true)
            }
            VStack(spacing: 6) {
                Text(titleKey)
                    .font(AppFont.title(18))
                    .foregroundStyle(AppColor.navyText)
                    .multilineTextAlignment(.center)
                if let subtitleKey {
                    Text(subtitleKey)
                        .font(AppFont.body(13))
                        .foregroundStyle(AppColor.navyText.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            if let actionTitleKey, let action {
                PrimaryButton(title: actionTitleKey, systemIcon: "plus") {
                    action()
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}
