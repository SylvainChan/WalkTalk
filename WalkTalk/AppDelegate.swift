//
//  AppDelegate.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 7/2/2020.
//  Copyright © 2020 Sylvain. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var vc: UIViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        window.frame = UIScreen.main.bounds
        window.makeKeyAndVisible()

        let entranceVC = EntranceBuilder.createScene(request: EntranceBuilder.BuildRequest())
        let navVC = UINavigationController(rootViewController: entranceVC)
        
        self.vc = navVC
        window.rootViewController = navVC
        self.window = window
        
        
        return true
    }
}

