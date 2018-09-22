
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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let provider = DeviceProvider()
        provider.regitserDevice(token: deviceToken.hexString)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
    }
    
}



