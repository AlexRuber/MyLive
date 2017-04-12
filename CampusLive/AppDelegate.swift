
//
//  AppDelegate.swift
//  CampusLive
//  
//  Created by Mihai Ruber on 1/21/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?

    var storyboard: UIStoryboard?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let tintColor = UIColor(red: 27/255, green: 150/255, blue: 254/255, alpha: 1.0)
        window!.tintColor = tintColor
        
       /* let defaults = UserDefaults.standard
        if defaults.value(forKey: "yourKey") != nil{
            
            var vc = UIViewController()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let value = defaults.value(forKey: "yourKey") as! String!
            let controller = storyboard.instantiateViewController(withIdentifier: "HomeView") as UIViewController!
            if value == "loggedin"{
                vc = storyboard.instantiateViewController(withIdentifier: "HomeView") as UIViewController!
            }
            else if value == "loggedOut"{
                vc = storyboard.instantiateViewController(withIdentifier: "LoginView") as UIViewController!
            }
            self.window?.rootViewController = controller
        }*/
        
        UIApplication.shared.statusBarStyle = .lightContent


        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir", size: 18)!, NSForegroundColorAttributeName: UIColor.white]
      
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        // Add any custom logic here.
        return handled
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

