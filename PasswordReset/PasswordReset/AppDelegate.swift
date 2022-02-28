//
//  AppDelegate.swift
//  PasswordReset
//
//  Created by scmc-mac3 on 28/02/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


   var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        window?.rootViewController = ViewController()
        
        return true
    }

  

}

