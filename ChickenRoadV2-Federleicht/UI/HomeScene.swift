import SwiftUI

struct HomeScene: View {
    @EnvironmentObject private var coop: CoopJournal
    @State private var pathSheet = false
    @State private var showCompletion = false
    @State private var lastDoneState: Bool = false
    let switchTab: (ShellTab) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                header
                chickenStage
                heartsRow
                progressCard
                quickCards
                PrimaryButton(title: "home.cta", systemIcon: "heart.fill", bigCTA: true) {
                    pathSheet = true
                }
                .padding(.horizontal, 22)
                eggsPill
                Spacer(minLength: 24)
            }
            .padding(.top, 12)
        }
        .appBackdrop()
        .overlay {
            if showCompletion {
                CompletionOverlay(streak: coop.streak) {
                    withAnimation(.bouncy(duration: 0.4, extraBounce: 0.2)) {
                        showCompletion = false
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .sheet(isPresented: $pathSheet) {
            CarePathScene().environmentObject(coop)
        }
        .onAppear {
            coop.rolloverIfNeeded()
            lastDoneState = coop.progress.is_done
            bootstrapNotificationsIfNeeded()
            if UserDefaults.standard.bool(forKey: "app.dev.path") {
                UserDefaults.standard.set(false, forKey: "app.dev.path")
                pathSheet = true
            }
        }
        .onChange(of: coop.progress.is_done) { _, newValue in
            if newValue && !lastDoneState {
                Haptics.success()
                withAnimation(.bouncy(duration: 0.6, extraBounce: 0.3)) {
                    showCompletion = true
                }
            }
            lastDoneState = newValue
        }
    }

    private func bootstrapNotificationsIfNeeded() {
        let key = "app.notifications.bootstrapped"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        Task {
            let granted = await ReminderScheduler.ensurePermission()
            guard granted else { return }
            let body = NSLocalizedString("reminders.notify.body", comment: "")
            for reminder in coop.reminders where reminder.isEnabled {
                ReminderScheduler.plant(reminder, body: body)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("home.greeting")
                    .font(AppFont.body(14, weight: .semibold))
                    .foregroundStyle(AppColor.navyText.opacity(0.6))
                Text(coop.chickenName.isEmpty ? NSLocalizedString("home.chicken_default", comment: "") : coop.chickenName)
                    .font(AppFont.title(24))
                    .foregroundStyle(AppColor.navyText)
            }
            Spacer()
            streakBadge
        }
        .padding(.horizontal, 22)
    }

    private var heartsRow: some View {
        let filled = max(0, min(5, coop.progress.completed))
        return VStack(spacing: 6) {
            Text("home.wellness.title")
                .font(AppFont.caption(11))
                .foregroundStyle(AppColor.navyText.opacity(0.55))
                .textCase(.uppercase)
                .tracking(0.5)
            HStack(spacing: 10) {
                ForEach(0..<5, id: \.self) { idx in
                    Image(systemName: idx < filled ? "heart.fill" : "heart")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(idx < filled ? AppColor.redAlert : AppColor.redAlert.opacity(0.25))
                        .scaleEffect(idx < filled ? 1.0 : 0.9)
                        .animation(.bouncy(duration: 0.5, extraBounce: 0.2), value: filled)
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.white)
                .shadow(color: AppColor.navyText.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }

    private var streakBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .foregroundStyle(AppColor.streakGold)
            Text("\(coop.streak)")
                .font(AppFont.numeric(18))
                .foregroundStyle(AppColor.navyText)
            Text("home.days_short")
                .font(AppFont.caption(12))
                .foregroundStyle(AppColor.navyText.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(Color.white)
                .shadow(color: AppColor.navyText.opacity(0.07), radius: 6, x: 0, y: 3)
        )
    }

    private var chickenStage: some View {
        ZStack(alignment: .bottom) {
            Image("home_stage")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            ChickenView(pose: .idle, accessory: coop.accessory, size: 180)
                .offset(y: 0)
        }
        .padding(.horizontal, 22)
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("home.progress.title")
                    .font(AppFont.body(15, weight: .heavy))
                    .foregroundStyle(AppColor.navyText)
                Spacer()
                Text("\(coop.progress.completed)/\(coop.progress.total)")
                    .font(AppFont.numeric(16))
                    .foregroundStyle(AppColor.navyText)
            }
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10).fill(AppColor.cream).frame(height: 14)
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [AppColor.grassGreen, AppColor.streakGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(14, geo.size.width * coop.progress.fraction), height: 14)
                }
                .frame(height: 14)
            }
            Text(coop.progress.is_done ? "home.progress.done" : "home.progress.keep")
                .font(AppFont.caption(13))
                .foregroundStyle(AppColor.navyText.opacity(0.6))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: AppColor.navyText.opacity(0.06), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 22)
    }

    private var quickCards: some View {
        VStack(spacing: 12) {
            ForEach(coop.dailyTasks.prefix(3)) { task in
                TaskCard(task: task) {
                    pathSheet = true
                }
            }
        }
        .padding(.horizontal, 22)
    }

    private var eggsPill: some View {
        Button {
            switchTab(.eggs)
        } label: {
            HStack(spacing: 14) {
                EggGlyph(size: 26, color: AppColor.streakGold)
                VStack(alignment: .leading, spacing: 2) {
                    Text("home.eggs.title")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColor.navyText.opacity(0.6))
                    Text("\(coop.totalEggs) · \(String(format: "%.1f", coop.averageEggsPerDay)) Ø")
                        .font(AppFont.body(15, weight: .heavy))
                        .foregroundStyle(AppColor.navyText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColor.navyText.opacity(0.4))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: AppColor.navyText.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(BouncyPressStyle())
        .padding(.horizontal, 22)
    }
}

private struct CompletionOverlay: View {
    let streak: Int
    let onDismiss: () -> Void

    @State private var pulse: CGFloat = 0.85

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture { onDismiss() }
            VStack(spacing: 18) {
                ZStack {
                    Image(systemName: "sparkle")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColor.streakGold)
                        .offset(x: -90, y: -50)
                        .scaleEffect(pulse)
                    Image(systemName: "sparkle")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColor.warmOrange)
                        .offset(x: 90, y: -70)
                        .scaleEffect(pulse)
                    Image(systemName: "sparkle")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColor.streakGold)
                        .offset(x: 80, y: 40)
                        .scaleEffect(pulse)
                    ChickenView(pose: .happy, accessory: .none, size: 200, isFloating: true)
                }
                Text("path.done.title")
                    .font(AppFont.title(24))
                    .foregroundStyle(AppColor.navyText)
                Text("path.done.text")
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColor.navyText.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill").foregroundStyle(AppColor.streakGold)
                    Text("\(streak)")
                        .font(AppFont.numeric(18))
                        .foregroundStyle(AppColor.navyText)
                    Text("day.complete.streak")
                        .font(AppFont.body(13, weight: .heavy))
                        .foregroundStyle(AppColor.warmOrange)
                }
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(Capsule().fill(Color.white).shadow(color: AppColor.navyText.opacity(0.1), radius: 6))
                PrimaryButton(title: "day.complete.cta", systemIcon: "checkmark") {
                    onDismiss()
                }
                .padding(.horizontal, 28)
            }
            .padding(.vertical, 30)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppColor.cream)
                    .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 12)
            )
            .padding(.horizontal, 22)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = 1.15
            }
        }
    }
}
