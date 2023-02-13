//
//  AKUpdateManager.swift
//  AKUpdateManager
//
//  Created by Amr Koritem on 12/02/2023.
//

import UIKit

public enum UpdatePriority {
    case major, minor, patch, none
}

public typealias UpdateAppHandler = (_ needUpdate: UpdatePriority, _ error: Error?) -> Void

public final class AKUpdateManager {
    public static let shared = AKUpdateManager()

    var defaultHandler: UpdateAppHandler = { updatePriority, error in
        let alert = UIAlertController(
            title: "App needs update",
            message: "A new update is available now.",
            preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default))
        guard updatePriority != .none,
              let window = UIApplication.shared.delegate?.createUpdaterWindow() else { return }
        alert.show(in: window)
    }

    private init() {}

    /// Check if the app needs updates.
    @discardableResult public func checkForUpdates(
        showDefaultAlert: Bool = false
    ) async -> (needUpdate: UpdatePriority, error: Error?) {
        let updateInfo = await withCheckedContinuation { continuation in
            checkForUpdates { needUpdate, error in
                continuation.resume(returning: (needUpdate: needUpdate, error: error))
            }
        }
        if showDefaultAlert {
            defaultHandler(updateInfo.needUpdate, updateInfo.error)
        }
        return updateInfo
    }

    /// Check if the app needs updates.
    public func checkForUpdates(_ completion: UpdateAppHandler? = nil) {
        let completion = completion ?? defaultHandler
        guard let info = Bundle.main.infoDictionary,
              let currentVersionString = info["CFBundleShortVersionString"] as? String,
              let identifier = info["CFBundleIdentifier"] as? String,
              let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)") else { return completion(.none, nil) }
        let currentVersion = AppVersion(version: currentVersionString)
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            do {
                if let error = error { return completion(.none, error) }
                guard let data = data else { return completion(.none, nil) }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any],
                      let versionString = result["version"] as? String else { return completion(.none, nil) }
                let version = AppVersion(version: versionString)
                let updatePriority = self?.compareVersions(new: version, current: currentVersion)
                completion(updatePriority ?? .none, nil)
            } catch {
                completion(.none, error)
            }
        }
        task.resume()
    }

    func compareVersions(
        new newVersion: AppVersion,
        current currentVersion: AppVersion
    ) -> UpdatePriority {
        if newVersion.major != currentVersion.major {
            return .major
        } else if newVersion.minor != currentVersion.minor {
            return .minor
        } else if newVersion.patch != currentVersion.patch {
            return .patch
        } else {
            return .none
        }
    }
}

struct AppVersion {
    let major: String
    let minor: String
    let patch: String

    init(version: String) {
        let parts = version.split(separator: ".")
        major = parts.first?.string ?? ""
        guard parts.count >= 3 else {
            minor = parts.last?.string ?? ""
            patch = "0"
            return
        }
        minor = parts[safe: 1]?.string ?? ""
        patch = parts.last?.string ?? ""
    }
}

final class UpdaterViewController: UIViewController {
    /// This creates a retain cycle.
    /// This is needed to retain the UIAlertController in iOS 13.0+
    var retainedWindow: UIWindow?

    deinit {
        retainedWindow = nil
    }
}

extension String.SubSequence {
    var string: String {
        String(self)
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension UIAlertController {
    /// Presents `UIAlertController` in a new `UIWindow`.
    func show(in window: UIWindow) {
        guard !isBeingPresented else { return }
        window.makeKeyAndVisible()
        window.rootViewController?.present(self, animated: true)
    }

    /// Hides `UIAlertController` within a given window.
    func hide(in window: UIWindow) {
        window.isHidden = true
    }
}

extension UIApplicationDelegate {
    var foregroundScene: UIWindowScene? {
        let connectedScenes = UIApplication.shared.connectedScenes
        let activeScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        let inactiveScene = connectedScenes.first(where: { $0.activationState == .foregroundInactive }) as? UIWindowScene
        return activeScene ?? inactiveScene
    }

    func createUpdaterWindow() -> UIWindow? {
        let window = { () -> UIWindow? in
            guard #available(iOS 13.0, *) else { return UIWindow(frame: UIScreen.main.bounds) }
            guard let windowScene = foregroundScene else { return nil }
            return UIWindow(windowScene: windowScene)
        }() ?? UIWindow()
        let viewController = UpdaterViewController()
        viewController.retainedWindow = window
        window.rootViewController = viewController
        return window
    }
}
