//
//  AppDelegate.swift
//  MoonCascadeTest
//
//  Created by Rinat Gabdullin on 11.03.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if ProcessInfo.processInfo.environment["XCInjectBundleInto"] != nil {
            return false
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = UIStoryboard(name: "Storyboard", bundle: nil).instantiateInitialViewController()!
        window!.makeKeyAndVisible()

        return true
    }



}

