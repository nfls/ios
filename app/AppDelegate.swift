
//
//  AppDelegate.swift
//  general
//
//  Created by 胡清阳 on 17/2/3.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications 
import Alamofire
import AlamofireNetworkActivityIndicator
import QuickLook
import Sentry

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    

    var window: UIWindow?
    var token:String = ""
    var isLaunched = false
    var isOn = true
    var time = Date().timeIntervalSince1970
    //var theme = ThemeManager()
    var url:String? = nil
    var isUnityRunning = false
    var application: UIApplication?
    var enableAllOrientation = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.application = application

        IQKeyboardManager.shared.enable = true
        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.completionDelay = 0.5
        UMAnalyticsConfig.sharedInstance().appKey = "59c733a1c895764c1100001c"
        UMAnalyticsConfig.sharedInstance().channelId = "App Store"
        MobClick.start(withConfigure: UMAnalyticsConfig.sharedInstance())
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        MobClick.setAppVersion(version as! String)
        MobClick.setEncryptEnabled(true)
        MobClick.setLogEnabled(true)
        
        do {
            Client.shared = try Client(dsn: "https://9fa2ea4914b74970a52473d16f103cfb:3e98c44859b04ef48139ccd4bf8f6b80@sentry.io/282832")
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
            // Wrong DSN or KSCrash not installed
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }
    

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
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

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return true
    }
}



