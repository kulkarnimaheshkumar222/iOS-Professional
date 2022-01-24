//
//  AppDelegate.swift
//  BankeyDemoApp
//
//  Created by scmc-mac3 on 31/12/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    
    let loginViewController = LoginViewController()
    let onboardingContainerViewController = OnboardingContainerViewController()
    let dummyVC = DummyViewController()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        onboardingContainerViewController.delegate = self
        loginViewController.delegate = self
        dummyVC.logoutDelegate = self
        window?.rootViewController = loginViewController
       // OnboardingContainerViewController
        return true
    }
}

extension AppDelegate: LoginViewControllerDelegate {
    func didLogin() {
        if (LocalState.hasOnBoarded) {
            setRootViewController(dummyVC)
            
        } else {
            setRootViewController(onboardingContainerViewController)
        }
    }
}
extension AppDelegate: OnboardingContainerViewControllerDelegate {
    func didFinishOnboarding() {
        print("foo-did Onboarding")
        LocalState.hasOnBoarded = true
        setRootViewController(dummyVC)
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

