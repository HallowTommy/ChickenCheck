import SwiftUI

extension View {
    func appBackdrop() -> some View {
        background(
            LinearGradient(
                colors: [AppColor.skyBlue.opacity(0.45), AppColor.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}
