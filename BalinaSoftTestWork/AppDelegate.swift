

import UIKit

public var token: String? {
    get {
        return UserDefaults.standard.string(forKey: "token")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "token")
    }
}

public var userID: String? {
    get {
        return UserDefaults.standard.string(forKey: "userID")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "userID")
    }
}

public var username: String? {
    get {
        return UserDefaults.standard.string(forKey: "username")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "username")
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        if let _ = token, token != "" {
            let storyboard = UIStoryboard(name: "Reveal", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
            let navigationController = UINavigationController(rootViewController: vc)
            self.window?.rootViewController = navigationController
            self.window!.makeKeyAndVisible()
            navigationController.setNavigationBarHidden(true, animated: false)
        } else {
            
            let storyboard = UIStoryboard(name: "LoginAndRegisterStoryboard", bundle: nil)
            if let vc = storyboard.instantiateInitialViewController() {
                let navigationController = UINavigationController(rootViewController: vc)
                self.window?.rootViewController = navigationController
                self.window!.makeKeyAndVisible()
                navigationController.setNavigationBarHidden(true, animated: false)
            }
        }
       
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


