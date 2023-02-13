//
//  AppDelegate.swift
//  Example
//
//  Created by Amr Koritem on 09/09/2022.
//

import UIKit
import AKUpdateManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AKUpdateManager.shared.checkForUpdates()
        return true
    }
}

