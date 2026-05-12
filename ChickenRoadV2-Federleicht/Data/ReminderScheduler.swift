import Foundation
import UserNotifications

enum ReminderScheduler {
    static func ensurePermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        return granted
    }

    static func plant(_ reminder: CareReminder, body: String) {
        let center = UNUserNotificationCenter.current()
        cut(reminder.id)
        if !reminder.isEnabled { return }
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString(reminder.titleKey, comment: "")
        content.body = body
        content.sound = .default
        for weekday in reminder.weekdays {
            var components = DateComponents()
            components.hour = reminder.hour
            components.minute = reminder.minute
            components.weekday = weekday
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let identifier = "\(reminder.id.uuidString)_\(weekday)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request)
        }
    }

    static func cut(_ id: UUID) {
        let center = UNUserNotificationCenter.current()
        let identifiers = (1...7).map { "\(id.uuidString)_\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    static func resync(_ reminders: [CareReminder], body: String) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        for reminder in reminders { plant(reminder, body: body) }
    }
}
