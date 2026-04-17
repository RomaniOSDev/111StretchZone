//
//  PersistenceManager.swift
//  97RaidAlert
//
//  Created by Xeova Nuoc on 28.02.2026.
//

import Foundation

final class AppLaunchDefaultsBridge {
    static let shared = AppLaunchDefaultsBridge()

    private let savedUrlKey = "LastUrl"
    private let hasShownContentViewKey = "HasShownContentView"
    private let hasSuccessfulWebViewLoadKey = "HasSuccessfulWebViewLoad"

    var savedUrl: String? {
        get {
            if let url = LastURLDefaultsEcho.lastUrl {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: savedUrlKey)
        }
        set {
            if let urlString = newValue {
                UserDefaults.standard.set(urlString, forKey: savedUrlKey)
                if let url = URL(string: urlString) {
                    LastURLDefaultsEcho.lastUrl = url
                }
            } else {
                UserDefaults.standard.removeObject(forKey: savedUrlKey)
                LastURLDefaultsEcho.lastUrl = nil
            }
        }
    }

    var hasShownContentView: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasShownContentViewKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasShownContentViewKey)
        }
    }

    var hasSuccessfulWebViewLoad: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasSuccessfulWebViewLoadKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSuccessfulWebViewLoadKey)
        }
    }

    private init() {}
}
