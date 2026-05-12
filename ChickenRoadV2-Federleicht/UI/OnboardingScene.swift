import SwiftUI

struct OnboardingScene: View {
    @Binding var is_onboarded: Bool
    @State private var page: Int = 0

    private let slides: [Slide] = [
        Slide(titleKey: "onb.1.title", textKey: "onb.1.text", pose: .happy, accent: AppColor.warmOrange),
        Slide(titleKey: "onb.2.title", textKey: "onb.2.text", pose: .idle, accent: AppColor.grassGreen),
        Slide(titleKey: "onb.3.title", textKey: "onb.3.text", pose: .happy, accent: AppColor.streakGold)
    ]

    var body: some View {
        VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if page < slides.count - 1 {
                        Button("onb.skip") { complete() }
                            .font(AppFont.body(15, weight: .semibold))
                            .foregroundStyle(AppColor.navyText.opacity(0.7))
                            .padding(.trailing, 24)
                            .padding(.top, 18)
                    }
                }
                .frame(height: 44)

                Text(stepText)
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColor.navyText.opacity(0.55))
                    .textCase(.uppercase)
                    .tracking(0.6)
                    .padding(.top, 4)

                TabView(selection: $page) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { idx, slide in
                        slideView(slide, isFinal: idx == slides.count - 1).tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                PrimaryButton(
                    title: page < slides.count - 1 ? "onb.next" : "onb.start",
                    systemIcon: page < slides.count - 1 ? "arrow.right" : "checkmark"
                ) {
                    if page < slides.count - 1 {
                        withAnimation(.bouncy(duration: 0.5, extraBounce: 0.2)) { page += 1 }
                    } else {
                        complete()
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 36)
        }
        .appBackdrop()
    }

    private func slideView(_ slide: Slide, isFinal: Bool) -> some View {
        VStack(spacing: 22) {
            Spacer()
            ZStack {
                Circle()
                    .fill(slide.accent.opacity(0.20))
                    .frame(width: 320, height: 320)
                    .blur(radius: 12)
                ChickenView(pose: slide.pose, accessory: .none, size: 240, isFloating: true)
                if isFinal {
                    Text("onb.almost")
                        .font(AppFont.body(13, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(AppColor.warmOrange).shadow(color: AppColor.warmOrange.opacity(0.4), radius: 6, x: 0, y: 3))
                        .offset(x: 110, y: -120)
                }
            }
            .frame(height: 320)
            VStack(spacing: 12) {
                Text(LocalizedStringKey(slide.titleKey))
                    .font(AppFont.title(26))
                    .foregroundStyle(AppColor.navyText)
                    .multilineTextAlignment(.center)
                Text(LocalizedStringKey(slide.textKey))
                    .font(AppFont.body(16))
                    .foregroundStyle(AppColor.navyText.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
            Spacer()
        }
    }

    private func complete() {
        withAnimation(.bouncy(duration: 0.6, extraBounce: 0.2)) {
            is_onboarded = true
        }
    }

    private var stepText: String {
        let format = NSLocalizedString("onb.step", comment: "")
        return String(format: format, page + 1, slides.count)
    }

    struct Slide {
        let titleKey: String
        let textKey: String
        let pose: ChickenPose
        let accent: Color
    }
}
