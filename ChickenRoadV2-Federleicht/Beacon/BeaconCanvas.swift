import SwiftUI
@preconcurrency import WebKit

@MainActor
final class BeaconNavigator: NSObject, ObservableObject {
    @Published var can_go_back = false
    @Published var can_go_forward = false
    @Published var is_busy = false
    @Published var progress_amount: Double = 0

    let canvas: WKWebView
    let originURL: URL

    private var watchers: [NSKeyValueObservation] = []
    private var reloadAttempts = 0
    private let reloadCeiling = 4

    init(target: URL, sessionCookies: [HTTPCookie] = []) {
        self.originURL = target

        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true

        let view = WKWebView(frame: .zero, configuration: configuration)
        view.allowsBackForwardNavigationGestures = true
        view.scrollView.bounces = true
        view.scrollView.contentInsetAdjustmentBehavior = .always
        view.isOpaque = false
        view.backgroundColor = .clear
        view.scrollView.backgroundColor = .clear
        self.canvas = view

        super.init()

        view.navigationDelegate = self
        watchers = [
            view.observe(\.canGoBack, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.can_go_back = wv.canGoBack }
            },
            view.observe(\.canGoForward, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.can_go_forward = wv.canGoForward }
            },
            view.observe(\.isLoading, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.is_busy = wv.isLoading }
            },
            view.observe(\.estimatedProgress, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.progress_amount = wv.estimatedProgress }
            }
        ]

        BeaconLog.write("Canvas init target=\(target.absoluteString) cookies=\(sessionCookies.count)")
        if sessionCookies.isEmpty {
            view.load(URLRequest(url: target))
        } else {
            let store = view.configuration.websiteDataStore.httpCookieStore
            Task { @MainActor [weak self] in
                for cookie in sessionCookies {
                    BeaconLog.write("Canvas set cookie \(cookie.name) domain=\(cookie.domain)")
                    await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                        store.setCookie(cookie) { cont.resume() }
                    }
                }
                BeaconLog.write("Canvas cookies set, loading target")
                self?.canvas.load(URLRequest(url: target))
            }
        }
    }

    private nonisolated static func isRetryableNetworkError(_ nsErr: NSError) -> Bool {
        guard nsErr.domain == NSURLErrorDomain else { return false }
        switch nsErr.code {
        case NSURLErrorTimedOut,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorDNSLookupFailed,
             NSURLErrorCannotConnectToHost,
             NSURLErrorCannotFindHost,
             NSURLErrorInternationalRoamingOff,
             NSURLErrorDataNotAllowed:
            return true
        default:
            return false
        }
    }

    deinit {
        watchers.forEach { $0.invalidate() }
    }

    func slipBack() { canvas.goBack() }
    func slipForward() { canvas.goForward() }
    func returnToOrigin() { canvas.load(URLRequest(url: originURL)) }
    func replay() { canvas.reload() }
}

extension BeaconNavigator: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url else { return .cancel }
        let scheme = (url.scheme ?? "").lowercased()
        if ["tel", "mailto", "itms-apps", "itms-appss"].contains(scheme) {
            await UIApplication.shared.open(url)
            return .cancel
        }
        if scheme == "https" || scheme == "http" || scheme == "about" {
            return .allow
        }
        return .cancel
    }

    nonisolated func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        let nsErr = error as NSError
        BeaconLog.write("Canvas didFail: \(nsErr.domain) \(nsErr.code) \(nsErr.localizedDescription)")
        if nsErr.domain == NSURLErrorDomain, nsErr.code == NSURLErrorCancelled { return }
        guard Self.isRetryableNetworkError(nsErr) else { return }
        Task { @MainActor [weak self] in
            await self?.scheduleReload(reason: "didFail \(nsErr.code)")
        }
    }

    nonisolated func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        BeaconLog.write("Canvas start nav → \(webView.url?.absoluteString ?? "nil")")
    }

    nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        BeaconLog.write("Canvas finish nav → \(webView.url?.absoluteString ?? "nil")")
        Task { @MainActor [weak self] in
            self?.reloadAttempts = 0
        }
    }

    nonisolated func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        let nsErr = error as NSError
        BeaconLog.write("Canvas didFailProvisional: \(nsErr.domain) \(nsErr.code) \(nsErr.localizedDescription) url=\(webView.url?.absoluteString ?? "nil")")
        if nsErr.domain == NSURLErrorDomain, nsErr.code == NSURLErrorCancelled { return }
        guard Self.isRetryableNetworkError(nsErr) else { return }
        Task { @MainActor [weak self] in
            await self?.scheduleReload(reason: "provisional \(nsErr.code)")
        }
    }

    private func scheduleReload(reason: String) async {
        guard reloadAttempts < reloadCeiling else {
            BeaconLog.write("Canvas reload limit reached (\(reloadAttempts)/\(reloadCeiling)) — giving up")
            return
        }
        reloadAttempts += 1
        let backoffSec = min(8, 1 << (reloadAttempts - 1))
        BeaconLog.write("Canvas reload #\(reloadAttempts) in \(backoffSec)s — \(reason)")
        try? await Task.sleep(nanoseconds: UInt64(backoffSec) * 1_000_000_000)
        if canvas.url == nil {
            canvas.load(URLRequest(url: originURL))
        } else {
            canvas.reload()
        }
    }
}

private struct BeaconStrip: UIViewRepresentable {
    let canvas: WKWebView
    func makeUIView(context: Context) -> WKWebView { canvas }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct BeaconCanvas: View {
    @StateObject private var pilot: BeaconNavigator

    init(target: URL) {
        let cookies = BeaconCheck.shared.sessionCookies
        _pilot = StateObject(wrappedValue: BeaconNavigator(target: target, sessionCookies: cookies))
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                BeaconStrip(canvas: pilot.canvas)
                    .ignoresSafeArea(edges: [.top, .horizontal])

                if pilot.is_busy {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(AppColor.warmOrange)
                            .frame(width: geo.size.width * pilot.progress_amount, height: 2)
                            .animation(.easeInOut(duration: 0.2), value: pilot.progress_amount)
                    }
                    .frame(height: 2)
                    .ignoresSafeArea(edges: [.top, .horizontal])
                }
            }

            BeaconCompass(pilot: pilot)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

private struct BeaconCompass: View {
    @ObservedObject var pilot: BeaconNavigator

    var body: some View {
        HStack(spacing: 0) {
            compassButton(icon: "chevron.left", enabled: pilot.can_go_back) { pilot.slipBack() }
            compassButton(icon: "chevron.right", enabled: pilot.can_go_forward) { pilot.slipForward() }
            compassButton(icon: "house.fill", enabled: true, weight: .semibold) { pilot.returnToOrigin() }
            compassButton(icon: "arrow.clockwise", enabled: true) { pilot.replay() }
        }
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(
            Color(red: 0.078, green: 0.078, blue: 0.078).ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle().fill(Color.white.opacity(0.06)).frame(height: 0.5),
            alignment: .top
        )
    }

    @ViewBuilder
    private func compassButton(
        icon: String,
        enabled: Bool,
        weight: Font.Weight = .regular,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            if enabled {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                action()
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: weight))
                .foregroundStyle(enabled ? Color.white.opacity(0.92) : Color.white.opacity(0.25))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .contentShape(Rectangle())
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }
}

struct BeaconRouter<Facade: View, Drape: View>: View {
    @StateObject private var pulse = BeaconCheck.shared
    let facade: () -> Facade
    let drape: (URL) -> Drape

    var body: some View {
        ZStack {
            facade()
            if pulse.didSettle, let url = pulse.unfoldedTarget {
                drape(url)
                    .transition(.opacity)
            }
        }
        .task { await pulse.awakeAndProbe() }
    }
}
