import Foundation

enum CareKind: String, Codable, CaseIterable, Identifiable {
    case feed
    case water
    case eggs
    case clean
    case health

    var id: String { rawValue }

    var labelKey: String {
        switch self {
        case .feed: return "care.feed.label"
        case .water: return "care.water.label"
        case .eggs: return "care.eggs.label"
        case .clean: return "care.clean.label"
        case .health: return "care.health.label"
        }
    }

    var subtitleKey: String {
        switch self {
        case .feed: return "care.feed.subtitle"
        case .water: return "care.water.subtitle"
        case .eggs: return "care.eggs.subtitle"
        case .clean: return "care.clean.subtitle"
        case .health: return "care.health.subtitle"
        }
    }

    var systemIcon: String {
        switch self {
        case .feed: return "cup.and.saucer.fill"
        case .water: return "drop.fill"
        case .eggs: return "oval.portrait.fill"
        case .clean: return "bubbles.and.sparkles.fill"
        case .health: return "cross.case.fill"
        }
    }

    static var dailyOrder: [CareKind] {
        [.feed, .water, .eggs, .clean, .health]
    }
}
