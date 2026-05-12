import Foundation
import SwiftUI

enum NoteCategory: String, Codable, CaseIterable, Identifiable {
    case behavior
    case health
    case feed
    case cleaning
    case seasonal

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .behavior: return "note.cat.behavior"
        case .health: return "note.cat.health"
        case .feed: return "note.cat.feed"
        case .cleaning: return "note.cat.cleaning"
        case .seasonal: return "note.cat.seasonal"
        }
    }

    var accentColor: Color {
        switch self {
        case .behavior: return AppColor.skyBlue
        case .health: return AppColor.redAlert
        case .feed: return AppColor.warmOrange
        case .cleaning: return AppColor.grassGreen
        case .seasonal: return AppColor.streakGold
        }
    }
}

struct ChickenNote: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var category: NoteCategory
    var body: String

    init(id: UUID = UUID(), date: Date = Date(), category: NoteCategory = .behavior, body: String = "") {
        self.id = id
        self.date = date
        self.category = category
        self.body = body
    }
}
