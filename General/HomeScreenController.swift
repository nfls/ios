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


class HomeScreenController:UIViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver{
    @IBOutlet weak var barItem: UIBarButtonItem!
    
    var productID = ""
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
    }
    
    @IBAction func closeCurrent(segue: UIStoryboardSegue){
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //vcCount += 1
        navigationItem.title = nil
        if(segue.identifier == "aboutUs"){
            let dest = segue.destination as! WikiViewController
            dest.restricted = true
        }
    }
    
    func getImage(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        if(UserDefaults.standard.value(forKey: "pic_end") as? Date != nil){
            let date = UserDefaults.standard.value(forKey: "pic_end") as! Date
            let today = Date()
            if(today>date){
                UserDefaults.standard.removeObject(forKey: "pic_path")
                UserDefaults.standard.removeObject(forKey: "pic_text")
                UserDefaults.standard.removeObject(forKey: "pic_end")
                UserDefaults.standard.removeObject(forKey: "pic_id")
            }
        }
        Alamofire.request("https://api.nfls.io/device/pics", headers: headers).responseJSON(completionHandler: {
            response in
            switch response.result{
            case .success(let json):
                let info = ((json as! [String:AnyObject])["info"]) as! [String:Any]
                if(((UserDefaults.standard.value(forKey: "pic_id") as? Int) == nil) || (UserDefaults.standard.value(forKey: "pic_id") as? Int)! < (info["id"] as! Int)){
                    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let fileURL = documentsURL.appendingPathComponent("startup.jpg")
                        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                    }
                    Alamofire.download((info["url"] as! String), to: destination).response { response in
                        if response.error == nil, let imagePath = response.destinationURL?.path {
                            debugPrint("Get a new picture!")
                            UserDefaults.standard.set("startup.jpg", forKey: "pic_path")
                            debugPrint(imagePath)
                            let before = info["invalid_after"] as? String
                            let text = info["text"] as! String
                            UserDefaults.standard.set(text, forKey: "pic_text")
                            let format = DateFormatter()
                            format.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
                            if(before != nil){
                                let date = format.date(from: before! + " GMT+08:00")
                                UserDefaults.standard.set(date, forKey: "pic_end")
                            }
                            UserDefaults.standard.set((info["id"] as! Int), forKey: "pic_id")
                        }
                    }
                }
                break
            default:
                break
            }
        })
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
            self.performSegue(withIdentifier: "aboutUs", sender: self)
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
                    self.getImage()
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
                                    let ok = UIAlertAction(title: "好的", style: .default, handler: nil)
                                    let never = UIAlertAction(title: "不再提醒本条", style: .cancel, handler: {
                                        action in
                                        UserDefaults.standard.set(id, forKey: "sysmes_id")
                                    })
                                    alert.addAction(ok)
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
                }
                break
            default:
                break
            }
        })
    }
}
