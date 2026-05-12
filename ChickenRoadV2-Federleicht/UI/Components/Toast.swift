import SwiftUI

struct ToastModel: Identifiable, Equatable {
    let id = UUID()
    let titleKey: LocalizedStringKey
    let glyph: String
    let tone: Color
}

struct ToastView: View {
    let toast: ToastModel

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(toast.tone.opacity(0.18)).frame(width: 36, height: 36)
                Image(systemName: toast.glyph)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(toast.tone)
            }
            Text(toast.titleKey)
                .font(AppFont.body(14, weight: .heavy))
                .foregroundStyle(AppColor.navyText)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: AppColor.navyText.opacity(0.12), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 22)
    }
}

struct ToastHost: ViewModifier {
    @Binding var toast: ToastModel?

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let current = toast {
                ToastView(toast: current)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        let id = current.id
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                            if toast?.id == id {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    toast = nil
                                }
                            }
                        }
                    }
            }
        }
        .animation(.bouncy(duration: 0.45, extraBounce: 0.2), value: toast)
    }
}

extension View {
    func toastHost(_ toast: Binding<ToastModel?>) -> some View {
        modifier(ToastHost(toast: toast))
    }
}
