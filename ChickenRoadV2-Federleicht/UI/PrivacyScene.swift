import SwiftUI

struct PrivacyScene: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let url = URL(string: AppConfig.policyURL) {
                BeaconCanvas(target: url)
            } else {
                fallbackPanel
            }

            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.black.opacity(0.55)))
            }
            .padding(.top, 8)
            .padding(.trailing, 12)
        }
    }

    private var fallbackPanel: some View {
        VStack(spacing: 12) {
            Text("privacy.fallback")
                .font(AppFont.body(15))
                .foregroundStyle(AppColor.navyText.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.cream.ignoresSafeArea())
    }
}
