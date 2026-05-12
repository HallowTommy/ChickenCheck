import SwiftUI

@main
struct CompanionApp: App {
    @StateObject private var coop = CoopJournal.shared
    @StateObject private var beacon = BeaconCheck.shared

    init() {
        BeaconCheck.shared.bootstrap(
            tracker: AppConfig.relayHost,
            token: AppConfig.relayKey,
            targets: AppConfig.relayTargets,
            window: AppConfig.relayWindow
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coop)
                .environmentObject(beacon)
                .preferredColorScheme(.light)
                .tint(AppColor.warmOrange)
        }
    }
}
