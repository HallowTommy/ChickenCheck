import SwiftUI

struct CarePathScene: View {
    @EnvironmentObject private var coop: CoopJournal
    @Environment(\.dismiss) private var dismiss
    @State private var sheet: CareKind?
    @State private var toast: ToastModel?

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 22) {
                    farmStage
                    legend
                    if coop.progress.is_done {
                        doneBanner
                    }
                    Spacer(minLength: 24)
                }
                .padding(.top, 12)
            }
        }
        .appBackdrop()
        .toastHost($toast)
        .sheet(item: $sheet) { kind in
            CareActionSheet(kind: kind, status: statusFor(kind)) {
                withAnimation(.bouncy(duration: 0.5, extraBounce: 0.2)) {
                    coop.mark(kind)
                }
                sheet = nil
            } reset: {
                withAnimation(.bouncy(duration: 0.4, extraBounce: 0.15)) {
                    coop.reopen(kind)
                }
                sheet = nil
            }
            .presentationDetents([.fraction(0.45), .medium])
        }
    }

    private func statusFor(_ kind: CareKind) -> CareStatus {
        coop.dailyTasks.first(where: { $0.kind == kind })?.status ?? .upcoming
    }

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(AppColor.navyText)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white))
            }
            Spacer()
            VStack(spacing: 2) {
                Text("path.title")
                    .font(AppFont.title(20))
                    .foregroundStyle(AppColor.navyText)
                Text("\(coop.progress.completed)/\(coop.progress.total)")
                    .font(AppFont.numeric(13))
                    .foregroundStyle(AppColor.navyText.opacity(0.6))
            }
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
    }

    private var farmStage: some View {
        ZStack {
            stageBackdrop
            VStack(spacing: 0) {
                Spacer().frame(height: 60)
                standsRow
                Spacer()
            }
            chickenOnPath
        }
        .frame(height: 280)
        .padding(.horizontal, 22)
    }

    private var stageBackdrop: some View {
        Image("home_stage")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var grassPatch: some View {
        HStack(spacing: 4) {
            Image(systemName: "leaf.fill").foregroundStyle(AppColor.grassGreen)
            Image(systemName: "leaf.fill").foregroundStyle(AppColor.grassGreen.opacity(0.7))
        }
        .font(.system(size: 18))
    }

    private var roadStrip: some View {
        ZStack {
            Capsule()
                .fill(AppColor.navyText.opacity(0.30))
                .frame(height: 36)
            HStack(spacing: 14) {
                ForEach(0..<10) { _ in
                    Capsule()
                        .fill(AppColor.roadYellow)
                        .frame(width: 18, height: 4)
                }
            }
        }
        .padding(.horizontal, 14)
    }

    private var standsRow: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(coop.dailyTasks) { task in
                CareStand(task: task) {
                    handleTap(task)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 6)
    }

    private func handleTap(_ task: CareTask) {
        if task.status == .completed {
            sheet = task.kind
        } else {
            Haptics.tap()
            withAnimation(.bouncy(duration: 0.7, extraBounce: 0.25)) {
                coop.mark(task.kind)
            }
            toast = ToastModel(titleKey: toastKey(for: task.kind), glyph: "checkmark", tone: AppColor.grassGreen)
        }
    }

    private func toastKey(for kind: CareKind) -> LocalizedStringKey {
        switch kind {
        case .feed: return "path.toast.feed"
        case .water: return "path.toast.water"
        case .eggs: return "path.toast.eggs"
        case .clean: return "path.toast.clean"
        case .health: return "path.toast.health"
        }
    }

    private var chickenOnPath: some View {
        let total = max(1, coop.dailyTasks.count)
        let activeIdx: Int = {
            if let i = coop.dailyTasks.firstIndex(where: { $0.status == .current }) { return i }
            if coop.dailyTasks.allSatisfy({ $0.status == .completed }) { return total - 1 }
            return 0
        }()
        return GeometryReader { geo in
            let stride = (geo.size.width - 24) / CGFloat(total)
            let xOffset = 12 + stride * (CGFloat(activeIdx) + 0.5)
            ZStack {
                ChickenView(pose: coop.progress.is_done ? .happy : .idle, accessory: coop.accessory, size: 120, isFloating: false)
                if coop.progress.is_done {
                    SparkleHalo()
                }
            }
            .position(x: xOffset, y: geo.size.height - 80)
            .animation(.bouncy(duration: 0.6, extraBounce: 0.2), value: activeIdx)
        }
    }

    private var legend: some View {
        HStack(spacing: 8) {
            legendDot(color: AppColor.grassGreen, key: "status.completed")
            legendDot(color: AppColor.roadYellow, key: "status.current")
            legendDot(color: AppColor.mutedGray.opacity(0.6), key: "status.upcoming")
            legendDot(color: AppColor.redAlert, key: "status.missed")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule().fill(Color.white)
                .shadow(color: AppColor.navyText.opacity(0.05), radius: 6, x: 0, y: 3)
        )
    }

    private func legendDot(color: Color, key: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(LocalizedStringKey(key))
                .font(AppFont.caption(11))
                .foregroundStyle(AppColor.navyText.opacity(0.7))
        }
    }

    private var doneBanner: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(AppColor.streakGold)
            Text("path.done.title")
                .font(AppFont.title(20))
                .foregroundStyle(AppColor.navyText)
            Text("path.done.text")
                .font(AppFont.body(15))
                .foregroundStyle(AppColor.navyText.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppColor.grassGreen.opacity(0.18))
        )
        .padding(.horizontal, 22)
    }

}

private struct SparkleHalo: View {
    @State private var pulse: CGFloat = 0.85

    var body: some View {
        ZStack {
            sparkle(size: 18, x: -55, y: -45)
            sparkle(size: 14, x: 60, y: -50)
            sparkle(size: 16, x: 55, y: 30)
            sparkle(size: 12, x: -60, y: 20)
        }
        .scaleEffect(pulse)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = 1.15
            }
        }
    }

    private func sparkle(size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Image(systemName: "sparkle")
            .font(.system(size: size, weight: .heavy))
            .foregroundStyle(AppColor.streakGold)
            .offset(x: x, y: y)
    }
}

private struct CareStand: View {
    let task: CareTask
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(haloColor)
                        .frame(width: 52, height: 52)
                        .shadow(color: iconColor.opacity(0.25), radius: 6, x: 0, y: 3)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 42, height: 42)
                    if task.kind == .eggs {
                        EggGlyph(size: 20, color: iconColor)
                    } else {
                        Image(systemName: task.kind.systemIcon)
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundStyle(iconColor)
                    }
                    if task.status == .completed {
                        ZStack {
                            Circle().fill(AppColor.grassGreen).frame(width: 18, height: 18)
                                .overlay(Circle().stroke(.white, lineWidth: 2))
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(.white)
                        }
                        .offset(x: 18, y: -18)
                    }
                    if task.status == .missed {
                        ZStack {
                            Circle().fill(AppColor.redAlert).frame(width: 18, height: 18)
                                .overlay(Circle().stroke(.white, lineWidth: 2))
                            Image(systemName: "exclamationmark")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(.white)
                        }
                        .offset(x: 18, y: -18)
                    }
                }
                Capsule()
                    .fill(Color.white)
                    .frame(height: 20)
                    .overlay(
                        Text(LocalizedStringKey(task.kind.labelKey))
                            .font(AppFont.caption(9))
                            .foregroundStyle(AppColor.navyText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 4)
                    )
                    .padding(.horizontal, 1)
                    .shadow(color: AppColor.navyText.opacity(0.10), radius: 4, x: 0, y: 2)
            }
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

    private var haloColor: Color {
        switch task.status {
        case .completed: return AppColor.grassGreen.opacity(0.30)
        case .current: return AppColor.roadYellow
        case .missed: return AppColor.redAlert.opacity(0.30)
        case .upcoming: return AppColor.cream
        }
    }
}

private struct CareActionSheet: View {
    let kind: CareKind
    let status: CareStatus
    let confirm: () -> Void
    let reset: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(AppColor.navyText.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
            ZStack {
                Circle()
                    .fill(iconBg)
                    .frame(width: 84, height: 84)
                if kind == .eggs {
                    EggGlyph(size: 44, color: iconFg)
                } else {
                    Image(systemName: kind.systemIcon)
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(iconFg)
                }
            }
            Text(LocalizedStringKey(kind.labelKey))
                .font(AppFont.title(22))
                .foregroundStyle(AppColor.navyText)
            Text(LocalizedStringKey(kind.subtitleKey))
                .font(AppFont.body(15))
                .foregroundStyle(AppColor.navyText.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            VStack(spacing: 10) {
                if status == .completed {
                    SecondaryButton(title: "path.action.reset", systemIcon: "arrow.counterclockwise") { reset() }
                } else {
                    PrimaryButton(title: "path.action.done", systemIcon: "checkmark") { confirm() }
                }
            }
            .padding(.horizontal, 22)
            Spacer()
        }
        .padding(.bottom, 12)
    }

    private var iconFg: Color {
        switch kind {
        case .feed: return AppColor.warmOrange
        case .water: return AppColor.skyBlue
        case .eggs: return AppColor.streakGold
        case .clean: return AppColor.grassGreen
        case .health: return AppColor.redAlert
        }
    }

    private var iconBg: Color { iconFg.opacity(0.18) }
}
