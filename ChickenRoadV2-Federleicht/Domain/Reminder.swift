import Foundation

struct CareReminder: Codable, Identifiable, Equatable {
    let id: UUID
    var titleKey: String
    var hour: Int
    var minute: Int
    var weekdays: Set<Int>
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        titleKey: String,
        hour: Int,
        minute: Int = 0,
        weekdays: Set<Int> = [1, 2, 3, 4, 5, 6, 7],
        isEnabled: Bool = true
    ) {
        self.id = id
        self.titleKey = titleKey
        self.hour = hour
        self.minute = minute
        self.weekdays = weekdays
        self.isEnabled = isEnabled
    }

    static var presets: [CareReminder] {
        [
            CareReminder(titleKey: "reminder.preset.feed", hour: 8),
            CareReminder(titleKey: "reminder.preset.water", hour: 10),
            CareReminder(titleKey: "reminder.preset.eggs", hour: 12),
            CareReminder(titleKey: "reminder.preset.health", hour: 18),
            CareReminder(titleKey: "reminder.preset.clean", hour: 11, weekdays: [1, 7]),
            CareReminder(titleKey: "reminder.preset.evening", hour: 20)
        ]
    }
}
