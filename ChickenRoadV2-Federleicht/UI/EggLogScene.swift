import SwiftUI

struct EggLogScene: View {
    @EnvironmentObject private var coop: CoopJournal
    @State private var addSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    basket
                    weeklyChart
                    statsRow
                    moodHint
                    recentList
                }
                .padding(.horizontal, 22)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .appBackdrop()
            .navigationTitle("eggs.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { addSheet = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundStyle(AppColor.warmOrange)
                    }
                }
            }
            .sheet(isPresented: $addSheet) {
                AddEggSheet { count, note in
                    coop.appendEgg(EggEntry(count: count, note: note))
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var basket: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LinearGradient(colors: [AppColor.cream, AppColor.warmOrange.opacity(0.18)], startPoint: .top, endPoint: .bottom))
                    .frame(height: 140)
                HStack(spacing: 14) {
                    Image(systemName: "basket.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(AppColor.warmOrange)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("eggs.basket.title")
                            .font(AppFont.title(20))
                            .foregroundStyle(AppColor.navyText)
                        Text("eggs.basket.subtitle")
                            .font(AppFont.body(13))
                            .foregroundStyle(AppColor.navyText.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.horizontal, 22)
            }
        }
    }

    private var weeklyChart: some View {
        let bins = coop.eggsByWeekday()
        let labels = ["eggs.day.mon", "eggs.day.tue", "eggs.day.wed", "eggs.day.thu", "eggs.day.fri", "eggs.day.sat", "eggs.day.sun"]
        let maxValue = bins.max() ?? 0
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Spacer()
                Text("eggs.week.title")
                    .font(AppFont.body(15, weight: .heavy))
                    .foregroundStyle(AppColor.navyText)
            }
            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { idx in
                    let isBest = maxValue > 0 && bins[idx] == maxValue
                    VStack(spacing: 6) {
                        Text(LocalizedStringKey(labels[idx]))
                            .font(AppFont.caption(11))
                            .foregroundStyle(AppColor.navyText.opacity(0.6))
                        ZStack {
                            Circle()
                                .fill(isBest ? AppColor.streakGold : AppColor.cream)
                                .frame(width: 32, height: 32)
                            Text("\(bins[idx])")
                                .font(AppFont.numeric(14))
                                .foregroundStyle(isBest ? AppColor.navyText : AppColor.navyText.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: AppColor.navyText.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private var moodHint: some View {
        let weekTotal = coop.eggsByWeekday().reduce(0, +)
        let avg = coop.averageEggsPerDay
        let weeklyAvg = avg * 7
        let messageKey: String = {
            if coop.eggLog.isEmpty { return "eggs.mood.empty" }
            if Double(weekTotal) >= weeklyAvg + 2 { return "eggs.mood.great" }
            if Double(weekTotal) >= weeklyAvg { return "eggs.mood.steady" }
            return "eggs.mood.gentle"
        }()
        return HStack(spacing: 10) {
            EggGlyph(size: 30, color: AppColor.warmOrange)
            Text(LocalizedStringKey(messageKey))
                .font(AppFont.body(13))
                .foregroundStyle(AppColor.navyText.opacity(0.75))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColor.warmOrange.opacity(0.12))
        )
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatPill(titleKey: "eggs.total", value: "\(coop.totalEggs)", systemIcon: "oval.portrait.fill", accent: AppColor.warmOrange)
            StatPill(titleKey: "eggs.average", value: String(format: "%.1f", coop.averageEggsPerDay), systemIcon: "chart.line.uptrend.xyaxis", accent: AppColor.grassGreen)
            StatPill(titleKey: "eggs.best", value: "\(coop.bestEggDay)", systemIcon: "star.fill", accent: AppColor.streakGold)
        }
    }

    private var recentList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("eggs.recent")
                    .font(AppFont.body(15, weight: .heavy))
                    .foregroundStyle(AppColor.navyText)
                Spacer()
            }
            if coop.eggLog.isEmpty {
                EmptyHint(
                    titleKey: "eggs.empty",
                    subtitleKey: "eggs.empty.sub",
                    actionTitleKey: "eggs.add.title"
                ) {
                    addSheet = true
                }
            } else {
                ForEach(coop.eggLog.prefix(20)) { entry in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(AppColor.streakGold.opacity(0.18)).frame(width: 40, height: 40)
                            EggGlyph(size: 22, color: AppColor.streakGold)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(entry.count) ")
                                .font(AppFont.body(15, weight: .heavy))
                                .foregroundStyle(AppColor.navyText)
                            +
                            Text(LocalizedStringKey(entry.count == 1 ? "eggs.unit.one" : "eggs.unit.many"))
                                .font(AppFont.body(13))
                                .foregroundStyle(AppColor.navyText.opacity(0.6))
                            Text(entry.date, format: .dateTime.day().month().hour().minute())
                                .font(AppFont.caption(12))
                                .foregroundStyle(AppColor.navyText.opacity(0.55))
                        }
                        Spacer()
                        Button { coop.removeEgg(entry.id) } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(AppColor.navyText.opacity(0.25))
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: AppColor.navyText.opacity(0.04), radius: 6, x: 0, y: 3)
                    )
                }
            }
        }
    }
}

private struct AddEggSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var count: Double = 3
    @State private var note: String = ""
    let onSave: (Int, String) -> Void

    var body: some View {
        VStack(spacing: 18) {
            Capsule().fill(AppColor.navyText.opacity(0.2)).frame(width: 36, height: 4).padding(.top, 8)
            Text("eggs.add.title").font(AppFont.title(22)).foregroundStyle(AppColor.navyText)
            HStack(spacing: 24) {
                stepperButton(systemIcon: "minus") {
                    if count > 0 { count -= 1; Haptics.tap() }
                }
                .disabled(count <= 0)
                .opacity(count <= 0 ? 0.3 : 1)
                VStack(spacing: 4) {
                    Text("\(Int(count))")
                        .font(AppFont.numeric(56))
                        .foregroundStyle(AppColor.warmOrange)
                    Text("eggs.add.count")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColor.navyText.opacity(0.6))
                }
                .frame(minWidth: 90)
                stepperButton(systemIcon: "plus") {
                    if count < 10 { count += 1; Haptics.tap() }
                }
                .disabled(count >= 10)
                .opacity(count >= 10 ? 0.3 : 1)
            }
            .padding(.vertical, 8)
            TextField(LocalizedStringKey("eggs.add.note"), text: $note, axis: .vertical)
                .font(AppFont.body(15))
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14).fill(AppColor.cream))
                .padding(.horizontal, 22)
            PrimaryButton(title: "common.save") {
                Haptics.success()
                onSave(Int(count), note)
                dismiss()
            }
            .padding(.horizontal, 22)
            Spacer()
        }
    }

    private func stepperButton(systemIcon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemIcon)
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Circle().fill(AppColor.warmOrange).shadow(color: AppColor.warmOrange.opacity(0.4), radius: 8, x: 0, y: 4))
        }
        .buttonStyle(BouncyPressStyle())
    }
}
