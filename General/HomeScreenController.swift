//
//  HomeScreenController.swift
//  NFLSers-iOS
//
//  Created by 胡清阳 on 2017/6/6.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import Alamofire
import SwiftIconFont
/*
class HomeScreenController:UIViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver{
    @IBOutlet weak var center: UIButton!
    @IBOutlet weak var ib: UIImageView!
    var productID = ""
    var handleUrl = ""
    var productsRequest = SKProductsRequest()
    var transactionInProgress = false
    var productsArray = [SKProduct]()
    override func viewDidLoad() {
 
 
        checkStatus()
        let application = UIApplication.shared
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        SKPaymentQueue.default().add(self)
        let productID:NSSet = NSSet(object: "2")
        let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
        
       // self.performSegue(withIdentifier: "ForumConnector", sender: "")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        internalHandler(url: handleUrl)
        if let username = UserDefaults.standard.value(forKey: "username") as? String{
            self.navigationItem.prompt = "Welcome back, " + username
        } else {
            self.navigationItem.prompt = "Welcome to NFLS.IO"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.navigationItem.prompt = "南外人"
        })
    }

}

*/
