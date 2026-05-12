import Foundation

struct DailyProgress {
    let total: Int
    let completed: Int

    var fraction: Double {
        if total == 0 { return 0 }
        return Double(completed) / Double(total)
    }

    var is_done: Bool {
        total > 0 && completed >= total
    }
}
