import Foundation
import UIKit

enum AppConfig {
    static let relayHost = "zumpwick.com"
    static let relayKey = "bsphyjyfnw2chnwftsfv98yw8b13q22t"
    static let relayWindow: TimeInterval = 12
    static let relayTargets: Set<Int>? = nil

    static let policyURL = "https://www.termsfeed.com/live/15536143-8610-44a8-bf8d-7d8b5f647537"
    static let supportMail = "jamnabilsi@icloud.com"

    static var marketingVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    static var displayName: String {
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String { return name }
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }

    static var relayHints: [String: String] {
        var hints: [String: String] = [:]
        hints["sub_id_1"] = Bundle.main.bundleIdentifier ?? "unknown"
        hints["sub_id_2"] = "\(marketingVersion)-\(buildNumber)"
        hints["sub_id_3"] = Locale.preferredLanguages.first ?? "en"
        if let idfv = UIDevice.current.identifierForVendor?.uuidString {
            hints["sub_id_4"] = idfv
        }
        hints["sub_id_5"] = "ios"
        return hints
    }
}
