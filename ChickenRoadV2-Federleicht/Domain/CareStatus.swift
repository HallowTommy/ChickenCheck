import SwiftUI

enum CareStatus: String, Codable {
    case completed
    case current
    case missed
    case upcoming

    var badgeKey: String {
        switch self {
        case .completed: return "status.completed"
        case .current: return "status.current"
        case .missed: return "status.missed"
        case .upcoming: return "status.upcoming"
        }
    }

    var badgeFill: Color {
        switch self {
        case .completed: return AppColor.grassGreen
        case .current: return AppColor.roadYellow
        case .missed: return AppColor.redAlert
        case .upcoming: return AppColor.mutedGray.opacity(0.6)
        }
    }

    var badgeForeground: Color {
        switch self {
        case .upcoming: return AppColor.navyText.opacity(0.8)
        default: return AppColor.navyText
        }
    }
}
