import Foundation

enum Accessory: String, Codable, CaseIterable, Identifiable {
    case none
    case bow
    case hat
    case glasses

    var id: String { rawValue }

    var labelKey: String {
        switch self {
        case .none: return "accessory.none"
        case .bow: return "accessory.bow"
        case .hat: return "accessory.hat"
        case .glasses: return "accessory.glasses"
        }
    }

    var assetName: String? {
        switch self {
        case .none: return nil
        case .bow: return "accessory_bow"
        case .hat: return "accessory_hat"
        case .glasses: return "accessory_glasses"
        }
    }
}
