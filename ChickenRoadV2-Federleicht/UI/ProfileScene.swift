import SwiftUI

struct ProfileScene: View {
    @EnvironmentObject private var coop: CoopJournal
    @State private var showCustomize = false
    @State private var showPrivacy = false
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    avatarCard
                    statsRow
                    section
                    footer
                }
                .padding(.horizontal, 22)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .appBackdrop()
            .navigationTitle("profile.title")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if UserDefaults.standard.bool(forKey: "app.dev.customize") {
                    UserDefaults.standard.set(false, forKey: "app.dev.customize")
                    showCustomize = true
                }
            }
            .sheet(isPresented: $showCustomize) {
                CustomizeScene().environmentObject(coop)
            }
            .sheet(isPresented: $showPrivacy) {
                PrivacyScene()
            }
            .sheet(isPresented: $showResetAlert) {
                ResetConfirmSheet {
                    coop.resetAll()
                    Haptics.warning()
                    showResetAlert = false
                } cancel: {
                    showResetAlert = false
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var avatarCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(AppColor.skyBlue.opacity(0.4)).frame(width: 130, height: 130)
                ChickenView(pose: .idle, accessory: coop.accessory, size: 120, isFloating: true)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(coop.chickenName.isEmpty ? NSLocalizedString("home.chicken_default", comment: "") : coop.chickenName)
                    .font(AppFont.title(20))
                    .foregroundStyle(AppColor.navyText)
                Text("profile.subtitle")
                    .font(AppFont.body(13))
                    .foregroundStyle(AppColor.navyText.opacity(0.6))
                Button { showCustomize = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text("profile.customize")
                    }
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColor.warmOrange)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: AppColor.navyText.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatPill(titleKey: "profile.stat.streak", value: "\(coop.streak)", systemIcon: "flame.fill", accent: AppColor.warmOrange)
            StatPill(titleKey: "profile.stat.best", value: "\(coop.bestStreak)", systemIcon: "trophy.fill", accent: AppColor.streakGold)
            StatPill(titleKey: "profile.stat.total", value: "\(coop.totalCleanDays)", systemIcon: "checkmark.seal.fill", accent: AppColor.grassGreen)
        }
    }

    private var section: some View {
        VStack(spacing: 0) {
            row(icon: "envelope.fill", titleKey: "profile.support", trailing: AppConfig.supportMail) {
                if let url = URL(string: "mailto:\(AppConfig.supportMail)") {
                    UIApplication.shared.open(url)
                }
            }
            divider
            row(icon: "lock.shield.fill", titleKey: "profile.privacy", trailing: nil) {
                showPrivacy = true
            }
            divider
            row(icon: "arrow.counterclockwise.circle.fill", titleKey: "profile.reset", trailing: nil, tone: AppColor.redAlert) {
                showResetAlert = true
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: AppColor.navyText.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private func row(icon: String, titleKey: LocalizedStringKey, trailing: String?, tone: Color = AppColor.warmOrange, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(tone.opacity(0.18)).frame(width: 36, height: 36)
                    Image(systemName: icon).foregroundStyle(tone)
                }
                Text(titleKey)
                    .font(AppFont.body(15, weight: .heavy))
                    .foregroundStyle(AppColor.navyText)
                Spacer()
                if let trailing {
                    Text(trailing)
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColor.navyText.opacity(0.55))
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(AppColor.navyText.opacity(0.35))
            }
            .padding(14)
        }
        .buttonStyle(BouncyPressStyle())
    }

    private var divider: some View {
        Rectangle().fill(AppColor.cream).frame(height: 1).padding(.horizontal, 14)
    }

    private var footer: some View {
        VStack(spacing: 4) {
            Text(verbatim: "v\(AppConfig.marketingVersion) (\(AppConfig.buildNumber))")
                .font(AppFont.caption(11))
                .foregroundStyle(AppColor.navyText.opacity(0.4))
            Text("profile.tagline")
                .font(AppFont.caption(11))
                .foregroundStyle(AppColor.navyText.opacity(0.4))
        }
        .padding(.top, 8)
    }
}

private struct ResetConfirmSheet: View {
    let confirm: () -> Void
    let cancel: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Capsule().fill(AppColor.navyText.opacity(0.2)).frame(width: 36, height: 4).padding(.top, 8)
            ZStack {
                Circle().fill(AppColor.redAlert.opacity(0.18)).frame(width: 84, height: 84)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundStyle(AppColor.redAlert)
            }
            Text("profile.reset.title")
                .font(AppFont.title(20))
                .foregroundStyle(AppColor.navyText)
                .multilineTextAlignment(.center)
            Text("profile.reset.body")
                .font(AppFont.body(14))
                .foregroundStyle(AppColor.navyText.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            VStack(spacing: 10) {
                PrimaryButton(title: "profile.reset.confirm", systemIcon: "trash.fill", fill: AppColor.redAlert) {
                    confirm()
                }
                SecondaryButton(title: "common.cancel") { cancel() }
            }
            .padding(.horizontal, 22)
            Spacer()
        }
        .padding(.bottom, 14)
        .appBackdrop()
    }
}
