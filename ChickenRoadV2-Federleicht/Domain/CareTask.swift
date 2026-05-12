import Foundation

struct CareTask: Codable, Identifiable, Equatable {
    let id: UUID
    let kind: CareKind
    var status: CareStatus
    var completedAt: Date?

    init(id: UUID = UUID(), kind: CareKind, status: CareStatus = .upcoming, completedAt: Date? = nil) {
        self.id = id
        self.kind = kind
        self.status = status
        self.completedAt = completedAt
    }

    static func freshDay(at date: Date = Date()) -> [CareTask] {
        let order = CareKind.dailyOrder
        return order.enumerated().map { idx, kind in
            CareTask(kind: kind, status: idx == 0 ? .current : .upcoming)
        }
    }
}
