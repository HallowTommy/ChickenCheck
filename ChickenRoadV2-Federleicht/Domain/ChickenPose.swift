import Foundation

enum ChickenPose: String, Codable, CaseIterable {
    case idle
    case happy
    case eating
    case drinking
    case layingEgg
    case sleeping
    case walking
    case sad

    var assetName: String {
        switch self {
        case .idle: return "chicken_idle"
        case .happy: return "chicken_happy"
        case .eating: return "chicken_eating"
        case .drinking: return "chicken_drinking"
        case .layingEgg: return "chicken_egg"
        case .sleeping: return "chicken_sleep"
        case .walking: return "chicken_walk"
        case .sad: return "chicken_sad"
        }
    }
}
