import SwiftUI

struct RemindersScene: View {
    @EnvironmentObject private var coop: CoopJournal
    @State private var sheet: ReminderSheetMode?

    var body: some View {
        NavigationStack {
            Group {
                if coop.reminders.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackdrop()
            .navigationTitle("reminders.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { sheet = .create } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundStyle(AppColor.warmOrange)
                    }
                }
            }
            .sheet(item: $sheet) { mode in
                ReminderEditor(initial: editorSeed(mode)) { value in
                    coop.upsertReminder(value)
                    Task {
                        let granted = await ReminderScheduler.ensurePermission()
                        if granted {
                            ReminderScheduler.plant(value, body: NSLocalizedString("reminders.notify.body", comment: ""))
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(coop.reminders) { reminder in
                    ReminderRow(reminder: reminder) {
                        sheet = .edit(reminder.id)
                    } toggle: {
                        var value = reminder
                        value.isEnabled.toggle()
                        coop.upsertReminder(value)
                        Task {
                            if value.isEnabled {
                                let granted = await ReminderScheduler.ensurePermission()
                                if granted {
                                    ReminderScheduler.plant(value, body: NSLocalizedString("reminders.notify.body", comment: ""))
                                }
                            } else {
                                ReminderScheduler.cut(value.id)
                            }
                        }
                    } remove: {
                        ReminderScheduler.cut(reminder.id)
                        coop.removeReminder(reminder.id)
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 8)
        }
    }

    private var emptyState: some View {
        EmptyHint(
            titleKey: "reminders.empty.title",
            subtitleKey: "reminders.empty",
            actionTitleKey: "reminders.add"
        ) { sheet = .create }
    }

    private func editorSeed(_ mode: ReminderSheetMode) -> CareReminder {
        switch mode {
        case .create:
            return CareReminder(titleKey: "reminder.preset.feed", hour: 8)
        case .edit(let id):
            return coop.reminders.first(where: { $0.id == id }) ?? CareReminder(titleKey: "reminder.preset.feed", hour: 8)
        }
    }
}

enum ReminderSheetMode: Identifiable {
    case create
    case edit(UUID)
    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let id): return id.uuidString
        }
    }
}

private struct ReminderRow: View {
    let reminder: CareReminder
    let onTap: () -> Void
    let toggle: () -> Void
    let remove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(AppColor.warmOrange.opacity(0.18)).frame(width: 44, height: 44)
                        Image(systemName: "bell.fill").foregroundStyle(AppColor.warmOrange)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedStringKey(reminder.titleKey))
                            .font(AppFont.body(15, weight: .heavy))
                            .foregroundStyle(AppColor.navyText)
                        Text(timeLabel)
                            .font(AppFont.caption(12))
                            .foregroundStyle(AppColor.navyText.opacity(0.6))
                    }
                    Spacer()
                }
            }
            Toggle("", isOn: Binding(get: { reminder.isEnabled }, set: { _ in toggle() }))
                .labelsHidden()
                .tint(AppColor.grassGreen)
            Menu {
                Button(role: .destructive) { remove() } label: {
                    Label("common.delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(AppColor.navyText.opacity(0.4))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: AppColor.navyText.opacity(0.05), radius: 6, x: 0, y: 3)
        )
    }

    private var timeLabel: String {
        let hh = String(format: "%02d", reminder.hour)
        let mm = String(format: "%02d", reminder.minute)
        if reminder.weekdays.count == 7 {
            return "\(hh):\(mm) · \(NSLocalizedString("reminders.daily", comment: ""))"
        }
        if reminder.weekdays == [1, 7] {
            return "\(hh):\(mm) · \(NSLocalizedString("reminders.weekend", comment: ""))"
        }
        return "\(hh):\(mm)"
    }
}

private struct ReminderEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var value: CareReminder
    let onSave: (CareReminder) -> Void

    init(initial: CareReminder, onSave: @escaping (CareReminder) -> Void) {
        _value = State(initialValue: initial)
        self.onSave = onSave
    }

    private let presets: [String] = [
        "reminder.preset.feed", "reminder.preset.water", "reminder.preset.eggs", "reminder.preset.health", "reminder.preset.clean"
    ]
    private let weekdays: [(Int, String)] = [
        (2, "wd.mon"), (3, "wd.tue"), (4, "wd.wed"), (5, "wd.thu"), (6, "wd.fri"), (7, "wd.sat"), (1, "wd.sun")
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("reminders.editor.label") {
                    Picker("reminders.editor.preset", selection: $value.titleKey) {
                        ForEach(presets, id: \.self) { key in
                            Text(LocalizedStringKey(key)).tag(key)
                        }
                    }
                }
                Section("reminders.editor.time") {
                    DatePicker(
                        LocalizedStringKey("reminders.editor.time"),
                        selection: Binding(
                            get: {
                                var comp = DateComponents()
                                comp.hour = value.hour
                                comp.minute = value.minute
                                return Calendar.current.date(from: comp) ?? Date()
                            },
                            set: { newDate in
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                value.hour = comps.hour ?? 8
                                value.minute = comps.minute ?? 0
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
                Section("reminders.editor.days") {
                    HStack(spacing: 6) {
                        ForEach(weekdays, id: \.0) { day, label in
                            let isOn = value.weekdays.contains(day)
                            Button {
                                if isOn { value.weekdays.remove(day) } else { value.weekdays.insert(day) }
                            } label: {
                                Text(LocalizedStringKey(label))
                                    .font(AppFont.caption(12))
                                    .foregroundStyle(isOn ? .white : AppColor.navyText)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(isOn ? AppColor.warmOrange : AppColor.cream)
                                    )
                            }
                        }
                    }
                }
            }
            .navigationTitle("reminders.editor.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("common.cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save") {
                        onSave(value)
                        dismiss()
                    }
                }
            }
        }
    }
}
