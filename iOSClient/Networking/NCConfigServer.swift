// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2022 Marino Faggiana
// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import UIKit
import NextcloudKit

// Downloads the CalDAV/CardDAV `.mobileconfig` (with the account's auth headers)
// and hands it to iOS via UIDocumentInteractionController so the system presents
// the "Install Profile" flow. This is browser-independent — the previous
// approach opened the profile URL in the default browser, which fails when the
// default browser is not Safari (only Safari registers a downloaded profile for
// installation), producing a redirect loop in e.g. Chrome.

@MainActor
final class NCConfigServer: NSObject, URLSessionDelegate, UIDocumentInteractionControllerDelegate {
    let controller: NCMainTabBarController?
    private var documentController: UIDocumentInteractionController?
    private var fileURL: URL?

    var windowScene: UIWindowScene? {
        SceneManager.shared.getWindowScene(controller: controller)
    }

    init(controller: NCMainTabBarController?) {
        self.controller = controller
    }

    // Start service
    func startService(url: URL, account: String) {
        let defaultSessionConfiguration = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultSessionConfiguration, delegate: self, delegateQueue: .main)
        var urlRequest = URLRequest(url: url)
        if let headers = NextcloudKit.shared.nkCommonInstance.getStandardHeaders(account: account) {
            urlRequest.headers = headers
        }

        let dataTask = defaultSession.dataTask(with: urlRequest) { data, _, error in
            if let error {
                Task { @MainActor in
                    await showErrorBanner(windowScene: self.windowScene, error: NKError(error: error))
                }
            } else if let data, !data.isEmpty {
                Task { @MainActor in
                    self.presentProfile(data: data)
                }
            }
        }
        dataTask.resume()
    }

    nonisolated func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        NCNetworking.shared.checkTrustedChallenge(session, didReceive: challenge, completionHandler: completionHandler)
    }

    // MARK: - Profile install

    private func presentProfile(data: Data) {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("configuration.mobileconfig")
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            Task { @MainActor in
                await showErrorBanner(windowScene: self.windowScene, error: NKError(error: error))
            }
            return
        }
        self.fileURL = fileURL

        DispatchQueue.main.async {
            guard let viewController = self.topViewController else { return }
            let documentController = UIDocumentInteractionController(url: fileURL)
            documentController.uti = "com.apple.mobileconfig"
            documentController.delegate = self
            self.documentController = documentController

            if !documentController.presentPreview(animated: true) {
                documentController.presentOptionsMenu(from: viewController.view.bounds, in: viewController.view, animated: true)
            }
        }
    }

    private var topViewController: UIViewController? {
        var top: UIViewController? = controller
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    private func cleanup() {
        if let fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
        fileURL = nil
        documentController = nil
    }

    // MARK: - UIDocumentInteractionControllerDelegate

    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return topViewController ?? UIViewController()
    }

    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        cleanup()
    }

    func documentInteractionControllerDidDismissOptionsMenu(_ controller: UIDocumentInteractionController) {
        cleanup()
    }
}
