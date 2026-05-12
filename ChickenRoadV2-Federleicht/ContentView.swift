import SwiftUI

struct ContentView: View {
    @AppStorage(PersistenceKeys.onboarded) private var is_onboarded: Bool = false

    var body: some View {
        BeaconRouter(
            facade: { facadeStack },
            drape: { url in BeaconCanvas(target: url) }
        )
    }

    @ViewBuilder
    private var facadeStack: some View {
        if is_onboarded {
            HomeShell()
        } else {
            OnboardingScene(is_onboarded: $is_onboarded)
        }
    }
}

struct HomeShell: View {
    @AppStorage("app.session.tab") private var tabRaw: String = "home"

    var body: some View {
        let tabBinding = Binding<ShellTab>(
            get: { ShellTab(rawValue: tabRaw) ?? .home },
            set: { tabRaw = $0.rawValue }
        )
        TabView(selection: tabBinding) {
            HomeScene(switchTab: { tabRaw = $0.rawValue })
                .tag(ShellTab.home)
                .tabItem {
                    Label("tab.home", systemImage: "house.fill")
                }

            EggLogScene()
                .tag(ShellTab.eggs)
                .tabItem {
                    Label("tab.eggs", systemImage: "oval.portrait.fill")
                }

            RemindersScene()
                .tag(ShellTab.reminders)
                .tabItem {
                    Label("tab.reminders", systemImage: "bell.fill")
                }

            NotesScene()
                .tag(ShellTab.notes)
                .tabItem {
                    Label("tab.notes", systemImage: "note.text")
                }

            ProfileScene()
                .tag(ShellTab.profile)
                .tabItem {
                    Label("tab.profile", systemImage: "person.crop.circle")
                }
        }
        .tint(AppColor.warmOrange)
    }
}

enum ShellTab: String, Hashable {
    case home, eggs, reminders, notes, profile
}
