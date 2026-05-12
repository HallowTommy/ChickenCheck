import Foundation

struct EggEntry: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var count: Int
    var note: String

    init(id: UUID = UUID(), date: Date = Date(), count: Int, note: String = "") {
        self.id = id
        self.date = date
        self.count = max(0, count)
        self.note = note
    }
}
