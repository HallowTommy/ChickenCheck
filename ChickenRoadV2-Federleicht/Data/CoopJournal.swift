import Foundation
import SwiftUI

@MainActor
final class CoopJournal: ObservableObject {
    static let shared = CoopJournal()

    @Published var dailyTasks: [CareTask] = []
    @Published var dayMarker: String = ""
    @Published var streak: Int = 0
    @Published var bestStreak: Int = 0
    @Published var totalCleanDays: Int = 0
    @Published var eggLog: [EggEntry] = []
    @Published var reminders: [CareReminder] = []
    @Published var notes: [ChickenNote] = []
    @Published var accessory: Accessory = .none
    @Published var chickenName: String = ""

    private let store = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        pull()
        rolloverIfNeeded()
    }

    func pull() {
        if let data = store.data(forKey: PersistenceKeys.dailyTasks),
           let decoded = try? decoder.decode([CareTask].self, from: data) {
            dailyTasks = decoded
        } else {
            dailyTasks = CareTask.freshDay()
        }
        dayMarker = store.string(forKey: PersistenceKeys.dayMarker) ?? DateHelpers.dayMarker()
        streak = store.integer(forKey: PersistenceKeys.streakValue)
        bestStreak = store.integer(forKey: PersistenceKeys.streakBest)
        totalCleanDays = store.integer(forKey: PersistenceKeys.totalCleanDays)
        if let data = store.data(forKey: PersistenceKeys.eggLog),
           let decoded = try? decoder.decode([EggEntry].self, from: data) {
            eggLog = decoded
        }
        if let data = store.data(forKey: PersistenceKeys.reminders),
           let decoded = try? decoder.decode([CareReminder].self, from: data) {
            reminders = decoded
        } else {
            reminders = CareReminder.presets
        }
        if let data = store.data(forKey: PersistenceKeys.notes),
           let decoded = try? decoder.decode([ChickenNote].self, from: data) {
            notes = decoded
        }
        if let raw = store.string(forKey: PersistenceKeys.accessory),
           let value = Accessory(rawValue: raw) {
            accessory = value
        }
        chickenName = store.string(forKey: PersistenceKeys.chickenName) ?? ""
    }

    func flush() {
        if let data = try? encoder.encode(dailyTasks) {
            store.set(data, forKey: PersistenceKeys.dailyTasks)
        }
        store.set(dayMarker, forKey: PersistenceKeys.dayMarker)
        store.set(streak, forKey: PersistenceKeys.streakValue)
        store.set(bestStreak, forKey: PersistenceKeys.streakBest)
        store.set(totalCleanDays, forKey: PersistenceKeys.totalCleanDays)
        if let data = try? encoder.encode(eggLog) {
            store.set(data, forKey: PersistenceKeys.eggLog)
        }
        if let data = try? encoder.encode(reminders) {
            store.set(data, forKey: PersistenceKeys.reminders)
        }
        if let data = try? encoder.encode(notes) {
            store.set(data, forKey: PersistenceKeys.notes)
        }
        store.set(accessory.rawValue, forKey: PersistenceKeys.accessory)
        store.set(chickenName, forKey: PersistenceKeys.chickenName)
    }

    func rolloverIfNeeded(now: Date = Date()) {
        let marker = DateHelpers.dayMarker(for: now)
        if marker == dayMarker && !dailyTasks.isEmpty { return }
        let yesterdayCompleted = dailyTasks.allSatisfy { $0.status == .completed }
        if !dayMarker.isEmpty {
            if yesterdayCompleted {
                streak += 1
                totalCleanDays += 1
                bestStreak = max(bestStreak, streak)
            } else {
                streak = 0
            }
        }
        dailyTasks = CareTask.freshDay(at: now)
        dayMarker = marker
        flush()
    }

    func mark(_ kind: CareKind, completedAt date: Date = Date()) {
        guard let idx = dailyTasks.firstIndex(where: { $0.kind == kind }) else { return }
        dailyTasks[idx].status = .completed
        dailyTasks[idx].completedAt = date
        if let nextIdx = dailyTasks.firstIndex(where: { $0.status == .upcoming }) {
            dailyTasks[nextIdx].status = .current
        }
        flush()
    }

    func reopen(_ kind: CareKind) {
        guard let idx = dailyTasks.firstIndex(where: { $0.kind == kind }) else { return }
        dailyTasks[idx].status = .current
        dailyTasks[idx].completedAt = nil
        flush()
    }

    var progress: DailyProgress {
        let total = dailyTasks.count
        let done = dailyTasks.filter { $0.status == .completed }.count
        return DailyProgress(total: total, completed: done)
    }

    var pose: ChickenPose {
        progress.is_done ? .happy : .idle
    }

    func appendEgg(_ entry: EggEntry) {
        eggLog.insert(entry, at: 0)
        flush()
    }

    func removeEgg(_ id: UUID) {
        eggLog.removeAll { $0.id == id }
        flush()
    }

    func eggsThisWeek() -> [EggEntry] {
        let monday = DateHelpers.startOfWeek()
        return eggLog.filter { $0.date >= monday }
    }

    func eggsByWeekday() -> [Int] {
        let entries = eggsThisWeek()
        var bins = Array(repeating: 0, count: 7)
        let calendar = Calendar.current
        for entry in entries {
            let raw = calendar.component(.weekday, from: entry.date)
            let mondayBased = (raw + 5) % 7
            bins[mondayBased] += entry.count
        }
        return bins
    }

    var totalEggs: Int { eggLog.reduce(0) { $0 + $1.count } }

    var averageEggsPerDay: Double {
        let days = Set(eggLog.map { DateHelpers.dayMarker(for: $0.date) }).count
        if days == 0 { return 0 }
        return Double(totalEggs) / Double(days)
    }

    var bestEggDay: Int { eggLog.map { $0.count }.max() ?? 0 }

    func upsertReminder(_ value: CareReminder) {
        if let idx = reminders.firstIndex(where: { $0.id == value.id }) {
            reminders[idx] = value
        } else {
            reminders.append(value)
        }
        flush()
    }

    func removeReminder(_ id: UUID) {
        reminders.removeAll { $0.id == id }
        flush()
    }

    func appendNote(_ value: ChickenNote) {
        notes.insert(value, at: 0)
        flush()
    }

    func updateNote(_ value: ChickenNote) {
        if let idx = notes.firstIndex(where: { $0.id == value.id }) {
            notes[idx] = value
            flush()
        }
    }

    func removeNote(_ id: UUID) {
        notes.removeAll { $0.id == id }
        flush()
    }

    func switchAccessory(_ value: Accessory) {
        accessory = value
        flush()
    }

    func renameChicken(_ value: String) {
        chickenName = value
        flush()
    }

    func resetAll() {
        store.removeObject(forKey: PersistenceKeys.dailyTasks)
        store.removeObject(forKey: PersistenceKeys.dayMarker)
        store.removeObject(forKey: PersistenceKeys.streakValue)
        store.removeObject(forKey: PersistenceKeys.streakBest)
        store.removeObject(forKey: PersistenceKeys.totalCleanDays)
        store.removeObject(forKey: PersistenceKeys.eggLog)
        store.removeObject(forKey: PersistenceKeys.reminders)
        store.removeObject(forKey: PersistenceKeys.notes)
        store.removeObject(forKey: PersistenceKeys.accessory)
        store.removeObject(forKey: PersistenceKeys.chickenName)
        store.removeObject(forKey: PersistenceKeys.onboarded)
        dailyTasks = CareTask.freshDay()
        dayMarker = DateHelpers.dayMarker()
        streak = 0
        bestStreak = 0
        totalCleanDays = 0
        eggLog = []
        reminders = CareReminder.presets
        notes = []
        accessory = .none
        chickenName = ""
        flush()
    }
}
