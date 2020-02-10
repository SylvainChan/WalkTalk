//
//  AppDelegate.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 7/2/2020.
//  Copyright © 2020 Sylvain. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var vc: UIViewController?
    
    var backgroundTask: UIBackgroundTaskIdentifier?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        window.frame = UIScreen.main.bounds
        window.makeKeyAndVisible()

        let entranceVC = EntranceBuilder.createScene(request: EntranceBuilder.BuildRequest())
        let navVC = UINavigationController(rootViewController: entranceVC)
        
        self.vc = navVC
        window.rootViewController = navVC
        self.window = window
        
        // push
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (can, error) in
            DispatchQueue.main.async {
                if can {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.backgroundTask = application.beginBackgroundTask(expirationHandler: { [weak self] in
            if let task = self?.backgroundTask {
                application.endBackgroundTask(task)
                self?.backgroundTask = UIBackgroundTaskIdentifier.invalid
            }
        })
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if let task = self.backgroundTask {
            application.endBackgroundTask(task)
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name.init(WTNotification.appWillTerminate.rawValue), object: nil)
    }
}

// MARK: - push
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        UserConnection.pushToken = deviceTokenString
        NotificationCenter.default.post(name: NSNotification.Name.init(WTNotification.pushTokenUpdated.rawValue), object: nil)
    }
}

