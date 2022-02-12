//
//  AppDelegate.swift
//  BankeyDemoApp
//
//  Created by scmc-mac3 on 31/12/21.
//

import UIKit

let appColor: UIColor = .systemTeal
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    
    let loginViewController = LoginViewController()
    let onboardingContainerViewController = OnboardingContainerViewController()
    let mainViewController = MainViewController()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        onboardingContainerViewController.delegate = self
        loginViewController.delegate = self
        
      displayLogin()
        registerForNotification()
       // OnboardingContainerViewController
        return true
    }
    func displayLogin() {
        setRootViewController(loginViewController)
    }
    func prepMainView() {
        let vc = mainViewController
        vc.setStatusBar()
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().backgroundColor = appColor
        
    }
    func displayNextScreen() {
        if (LocalState.hasOnBoarded) {
            prepMainView()
            setRootViewController(mainViewController)
            
        } else {
            setRootViewController(onboardingContainerViewController)
        }
    }
}

extension AppDelegate: LoginViewControllerDelegate {
    func didLogin() {
        displayNextScreen()
    }
}
extension AppDelegate: OnboardingContainerViewControllerDelegate {
    func didFinishOnboarding() {
        print("foo-did Onboarding")
        LocalState.hasOnBoarded = true
        prepMainView()
        setRootViewController(mainViewController)
    }
    
}

extension AppDelegate: LogOutDelegate {
    func didLogout() {
        print("foo-did Logout")
        setRootViewController(loginViewController)
    }
    
}

extension AppDelegate {
    func setRootViewController(_ vc: UIViewController , animated: Bool = true) {
        guard animated , let window = self.window else {
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
            return
        }
        window.rootViewController = vc
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.7,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
}

extension AppDelegate {
    func registerForNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didLogOut), name: .logout, object: nil)
    }
    
    @objc func didLogOut() {
        setRootViewController(loginViewController)
    }
}
