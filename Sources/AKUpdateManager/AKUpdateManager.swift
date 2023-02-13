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

public typealias UpdateAppResult = (updatePriority: UpdatePriority, error: Error?)
public typealias UpdateAppHandler = (_ result: UpdateAppResult) -> Void

protocol AKUpdateManagerProtocol {
    var storeLink: String? { get }
    var currentVersion: AppVersion? { get }
    func openStoreLink()
    func checkForUpdates(showDefaultAlert: Bool) async -> UpdateAppResult
    func checkForUpdates(_ completion: UpdateAppHandler?)
}

extension AKUpdateManagerProtocol {
    func checkForUpdates() async -> UpdateAppResult {
        await checkForUpdates(showDefaultAlert: false)
    }

    func checkForUpdates() {
        checkForUpdates(nil)
    }
}

public final class AKUpdateManager: AKUpdateManagerProtocol {
    public static let shared = AKUpdateManager()

    public var storeLink: String? {
        let info = Bundle.main.infoDictionary
        guard let identifier = info?["CFBundleIdentifier"] as? String else { return nil }
        return "https://itunes.apple.com/lookup?bundleId=\(identifier)"
    }
    public var currentVersion: AppVersion? {
        let info = Bundle.main.infoDictionary
        let currentVersionStr = info?["CFBundleShortVersionString"] as? String
        guard let currentVersionStr = currentVersionStr else { return nil }
        return AppVersion(version: currentVersionStr)
    }

    var defaultHandler: UpdateAppHandler = { result in
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.createUpdaterWindow() else { return }
            let alert = UIAlertController(
                title: "App needs update",
                message: "A new update is available now.",
                preferredStyle: .alert)
            let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
                AKUpdateManager.shared.openStoreLink()
            }
            let delayAction = UIAlertAction(title: "Next time", style: .default) { _ in
                alert.hide(in: window)
            }
            alert.addAction(updateAction)
            if result.updatePriority != .major {
                alert.addAction(delayAction)
            }
            guard result.updatePriority != .none else { return }
            alert.show(in: window)
        }
    }

    private init() {}

    public func openStoreLink() {
        storeLink?.openUrl()
    }

    /// Check if the app needs updates.
    @discardableResult public func checkForUpdates(
        showDefaultAlert: Bool = false
    ) async -> UpdateAppResult {
        let updateInfo = await withCheckedContinuation { continuation in
            checkForUpdates { updateInfo in
                continuation.resume(returning: updateInfo)
            }
        }
        if showDefaultAlert {
            defaultHandler(updateInfo)
        }
        return updateInfo
    }

    /// Check if the app needs updates.
    public func checkForUpdates(_ completion: UpdateAppHandler? = nil) {
        let completion = completion ?? defaultHandler
        guard let currentVersion = currentVersion,
              let storeLink = storeLink,
              let url = URL(string: storeLink) else { return completion((.none, nil)) }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            do {
                if let error = error {
                    return completion((updatePriority: .none, error: error))
                }
                guard let data = data else { return completion((.none, nil)) }
                let json = try JSONSerialization.jsonObject(
                    with: data,
                    options: [.allowFragments]
                ) as? [String: Any]
                let result = (json?["results"] as? [Any])?.first as? [String: Any]
                guard let versionString = result?["version"] as? String else { return completion((.none, nil)) }
                let version = AppVersion(version: versionString)
                let updatePriority = self?.compareVersions(
                    new: version,
                    current: currentVersion
                )
                completion((updatePriority: updatePriority ?? .none, error: nil))
            } catch {
                completion((updatePriority: .none, error: error))
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

public struct AppVersion {
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

extension String {
    /// Returns true if the url is opened successfully.
    @discardableResult func openUrl() -> Bool {
        guard let url = URL(string: "\(self)"), UIApplication.shared.canOpenURL(url) else { return false }
        guard #available(iOS 10.0, *) else {
            UIApplication.shared.openURL(url)
            return true
        }
        UIApplication.shared.open(url)
        return true
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
