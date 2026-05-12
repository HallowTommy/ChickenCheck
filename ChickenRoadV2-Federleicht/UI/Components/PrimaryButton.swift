import SwiftUI

struct PrimaryButton: View {
    let title: LocalizedStringKey
    var systemIcon: String? = nil
    var fill: Color = AppColor.warmOrange
    var foreground: Color = .white
    var bigCTA: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 10) {
                if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: bigCTA ? 18 : 16, weight: .heavy))
                }
                Text(title)
                    .font(AppFont.title(bigCTA ? 20 : 18))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, bigCTA ? 20 : 16)
            .background(
                RoundedRectangle(cornerRadius: bigCTA ? 26 : 22, style: .continuous)
                    .fill(fill)
                    .shadow(color: fill.opacity(0.45), radius: bigCTA ? 18 : 14, x: 0, y: bigCTA ? 12 : 8)
            )
        }
        .buttonStyle(BouncyPressStyle())
    }
}

struct SecondaryButton: View {
    let title: LocalizedStringKey
    var systemIcon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: 14, weight: .bold))
                }
                Text(title)
                    .font(AppFont.body(16, weight: .semibold))
            }
            .foregroundStyle(AppColor.navyText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppColor.navyText.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(BouncyPressStyle())
    }
}

struct BouncyPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.bouncy(duration: 0.45, extraBounce: 0.3), value: configuration.isPressed)
    }
}
