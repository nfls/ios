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


class HomeScreenController:UIViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver{
    @IBOutlet weak var barItem: UIBarButtonItem!
    @IBOutlet weak var ibbutton: UIButton!
    
    @IBOutlet weak var center: UIButton!
    @IBOutlet weak var ib: UIImageView!
    var productID = ""
    var productsRequest = SKProductsRequest()
    var transactionInProgress = false
    var productsArray = [SKProduct]()
    @IBOutlet weak var optionsRealButton: UIButton!
    
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    override func viewDidLoad() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(HomeScreenController.tapDetected))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        ib.isUserInteractionEnabled = true
        ib.addGestureRecognizer(singleTap)
        checkStatus()
        optionsButton.icon(from: .FontAwesome, code: "wrench", ofSize: 20)
        optionsRealButton.toolbarPlaceholder = "wrench"
        optionsRealButton.parseIcon()
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
    }
    @objc func tapDetected() {
        self.performSegue(withIdentifier: "showIC", sender: self)
    }
    
    @IBAction func closeCurrent(segue: UIStoryboardSegue){
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //vcCount += 1
        navigationItem.title = nil
        if(segue.identifier == "showWiki"){
            let dest = segue.destination as! WikiViewController
            if(sender as? String != nil){
                dest.in_url = sender as! String
            }
        } else if (segue.identifier == "showForum"){
            let dest = segue.destination as! ForumViewer
            if(sender as? String != nil){
                dest.in_url = sender as! String
            }
        }
    }
    
    
    @IBAction func settings(_ sender: Any) {
        let dialog = UIAlertController(title: "选项", message: "您的捐助是我们前进的动力。点击下面按钮给我们捐赠30元，所有款项将被用于服务器支出，您的用户名将公布在我们的感谢榜上。", preferredStyle: .actionSheet)
        let exit = UIAlertAction(title: "退出", style: .destructive, handler: {
            action in
            if let bundle = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundle)
            }
            self.performSegue(withIdentifier: "exit", sender: self)
        })
        let donate = UIAlertAction(title: "请喝咖啡", style: .default, handler: {
            action in
            let payment = SKPayment(product: self.productsArray[0] as SKProduct)
            SKPaymentQueue.default().add(payment)
            self.transactionInProgress = true
        })
        let opensourceInfo = UIAlertAction(title: "开源组件许可", style: .default, handler: {
            action in
            self.performSegue(withIdentifier: "showOpenSource", sender: self)
            
        })
        let aboutUs = UIAlertAction(title:"关于我们", style:.default, handler:{
            action in
            self.performSegue(withIdentifier: "showWiki", sender: "w/%E5%85%B3%E4%BA%8E%E6%88%91%E4%BB%AC")
        })
        let cancel = UIAlertAction(title: "返回", style: .cancel, handler: nil)
        dialog.addAction(donate)
        dialog.addAction(opensourceInfo)
        dialog.addAction(aboutUs)
        dialog.addAction(exit)
        dialog.addAction(cancel)
        dialog.popoverPresentationController?.barButtonItem = barItem
        self.present(dialog, animated: true)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                let receiptURL = Bundle.main.appStoreReceiptURL;
                let receipt = NSData(contentsOf: receiptURL!)
                let parameters: Parameters = [
                    "receipt": receipt!.base64EncodedString(options: .endLineWithCarriageReturn)
                ]
                let headers: HTTPHeaders = [
                    "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
                ]
                Alamofire.request("https://api.nfls.io/device/purchase", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response(completionHandler: { (response) in
                    /*
                    print(response.response)
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        print("Data: \(utf8Text)")
                    }
                    */
            })
                
                
            case SKPaymentTransactionState.failed:
                print("Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    func checkStatus(){
        if(UserDefaults.standard.string(forKey: "token") == nil){
            if let bundle = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundle)
            }
            self.performSegue(withIdentifier: "exit", sender: self)
            return
        }
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/device/status", headers: headers).responseJSON(completionHandler: {
            response in
            switch response.result{
            case .success(let json):
                if((json as! [String:Int])["code"]! != 200){
                    if let bundle = Bundle.main.bundleIdentifier {
                        UserDefaults.standard.removePersistentDomain(forName: bundle)
                    }
                    self.performSegue(withIdentifier: "exit", sender: self)
                } else {
                    let headers: HTTPHeaders = [
                        "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
                    ]
                    self.getBadge()
                    //self.getImage()
                    Alamofire.request("https://api.nfls.io/center/last",headers: headers).responseJSON(completionHandler: {
                        response in
                        switch response.result{
                        case .success(let json):
                            if((json as! [String:AnyObject])["code"]! as! Int == 200){
                                //dump(json)
                                let info = (json as! [String:AnyObject])["info"]! as! [String:Any]
                                let text = info["text"]! as! String
                                let title = info["title"]! as! String
                                let id = info["id"]! as! Int
                                if(UserDefaults.standard.object(forKey: "sysmes_id") as? Int != id ){
                                    let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
                                    let ok = UIAlertAction(title: "我知道了", style: .default, handler: nil)
                                    let never = UIAlertAction(title: "不再提醒", style: .cancel, handler: {
                                        action in
                                        UserDefaults.standard.set(id, forKey: "sysmes_id")
                                    })
                                    if(info["push"] as! String != ""){
                                        let show = UIAlertAction(title: "显示详情", style: .default, handler: { (action) in
                                            let jsonString = info["push"] as! String
                                            let data = jsonString.data(using: .utf8)!
                                            let things = try! JSONSerialization.jsonObject(with: data) as! [String:String]
                                            let type = things["type"]!
                                            let in_url = things["url"]!
                                            switch(type){
                                            case "forum":
                                                self.performSegue(withIdentifier: "showForum", sender: in_url)
                                                break
                                            case "wiki":
                                                self.performSegue(withIdentifier: "showWiki", sender: in_url)
                                                break
                                            default:
                                                break
                                            }
                                        })
                                        alert.addAction(show)
                                    } else {
                                        alert.addAction(ok)
                                    }
                                    alert.addAction(never)
                                    self.present(alert, animated: true, completion: nil)
                                    
                                }
                            }
                            break
                        default:
                            break
                        }
                    })
                }
                break
            default:
                let alert = UIAlertController(title: "提示", message: "网络连接异常！", preferredStyle: .alert)
                let ok = UIAlertAction(title: "好的", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                break
            }

        })
    }
    func getBadge(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/count",headers: headers).responseJSON(completionHandler: {
            response in
            switch response.result{
            case .success(let json):
                if((json as! [String:AnyObject])["code"]! as! Int == 200){
                    UIApplication.shared.applicationIconBadgeNumber = ((json as! [String:Any])["info"] as! Int)
                    if(UIApplication.shared.applicationIconBadgeNumber != 0){
                        self.center.setTitle("账户[New]", for: .normal)
                    }else{
                        self.center.setTitle("账户", for: .normal)
                    }
                }
                break
            default:
                break
            }
        })
    }
}
