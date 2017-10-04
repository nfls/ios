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
    @IBOutlet weak var center: UIButton!
    @IBOutlet weak var ib: UIImageView!
    var productID = ""
    var handleUrl = ""
    var productsRequest = SKProductsRequest()
    var transactionInProgress = false
    var productsArray = [SKProduct]()
    override func viewDidLoad() {
        navigationItem.title = "Homepage"
        removeFile(filename: "", path: "temp")
        let rightButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(settings))
        rightButton.icon(from: .FontAwesome, code: "cog", ofSize: 20)
        navigationItem.rightBarButtonItem = rightButton
        let leftButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(showUpdates))
        leftButton.icon(from: .FontAwesome, code: "rss", ofSize: 20)
        navigationItem.leftBarButtonItem = leftButton
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        ib.isUserInteractionEnabled = true
        ib.addGestureRecognizer(singleTap)
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
    @objc func tapDetected() {
        self.performSegue(withIdentifier: "showICNews", sender: self)
    }
    
    @objc func showUpdates(){
        self.performSegue(withIdentifier: "showUpdates", sender: self)
    }
    
    @IBAction func closeCurrent(segue: UIStoryboardSegue){
        
    }

    func removeFile(filename:String,path:String){
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("downloads").appendingPathComponent(path.removingPercentEncoding!).appendingPathComponent(filename)
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: fileURL.path)
        } catch {
            //print("removeError")
        }
        
    }
    
    @objc func settings() {
        let dialog = UIAlertController(title: "Operations", message: "You can click on the 'Buy Us A Coffee' to donate 30 RMB for us. Your name will be on the list of donators, and the use of that money will be publicized.", preferredStyle: .actionSheet)
        let exit = UIAlertAction(title: "Logout", style: .destructive, handler: {
            action in
            if let bundle = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundle)
            }
            self.performSegue(withIdentifier: "exit", sender: self)
        })
        let donate = UIAlertAction(title: "Buy Us A Coffee", style: .default, handler: {
            action in
            let payment = SKPayment(product: self.productsArray[0] as SKProduct)
            SKPaymentQueue.default().add(payment)
            self.transactionInProgress = true
        })
        let opensourceInfo = UIAlertAction(title: "Licenses", style: .default, handler: {
            action in
            self.performSegue(withIdentifier: "showOpenSource", sender: self)
            
        })
        let aboutUs = UIAlertAction(title:"About", style:.default, handler:{
            action in
            self.performSegue(withIdentifier: "showWiki", sender: "w/%E5%85%B3%E4%BA%8E%E6%88%91%E4%BB%AC")
        })
        var title = "Accounts"
        if(UIApplication.shared.applicationIconBadgeNumber > 0){
            title += " ["+String(describing:UIApplication.shared.applicationIconBadgeNumber)+" New Message(s)]"
        }
        let userCenter = UIAlertAction(title:title, style:.default, handler:{
            action in
            self.performSegue(withIdentifier: "showUserCenter", sender: self)
        })
        let cancel = UIAlertAction(title: "Back", style: .cancel, handler: nil)
        dialog.addAction(donate)
        dialog.addAction(opensourceInfo)
        dialog.addAction(userCenter)
        dialog.addAction(aboutUs)
        dialog.addAction(exit)
        dialog.addAction(cancel)
        dialog.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
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
                    MobClick.profileSignIn(withPUID: (String(describing: (json as! [String:Int])["id"]!)))
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
                                    let ok = UIAlertAction(title: "Got It", style: .default, handler: nil)
                                    let never = UIAlertAction(title: "Never Notice This Again", style: .cancel, handler: {
                                        action in
                                        UIApplication.shared.applicationIconBadgeNumber = 0
                                        UserDefaults.standard.set(id, forKey: "sysmes_id")
                                    })
                                    if(info["push"] as? String != nil && info["push"] as? String != ""){
                                        let show = UIAlertAction(title: "Show Details", style: .default, handler: { (action) in
                                            let jsonString = info["push"] as! String
                                            let data = jsonString.data(using: .utf8)!
                                            let things = try! JSONSerialization.jsonObject(with: data) as! [String:String]
                                            let type = things["type"]!
                                            let in_url = things["url"]!
                                            self.jumpToSection(type: type, in_url: in_url)
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
                    Alamofire.request("https://api.nfls.io/center/username",headers: headers).responseJSON(completionHandler: {
                        response in
                        switch(response.result){
                        case .success(let json):
                            let username = (json as! [String:Any])["info"] as! String
                            UserDefaults.standard.set(username, forKey: "username")
                            break
                        default:
                            break
                        }
                    })
                    self.performSegue(withIdentifier: "showUpdates", sender: self)
                }
                break
            default:
                let alert = UIAlertController(title: "Error", message: "Network or server error!", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                break
            }
            
        })
    }
    func internalHandler(url:String){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        handleUrl = ""
        if(url.contains("nfls.io")){
            if(!url.contains("https://nfls.io")){
                let tUrl = url.replacingOccurrences(of: "https://", with: "")
                let typeEndIndex = tUrl.index(of: ".nfls.io")!
                var in_url = ""
                if(!url.hasSuffix(".nfls.io")){
                    let urlStartIndex = tUrl.endIndex(of: ".nfls.io/")!
                    in_url = String(tUrl[urlStartIndex...])
                }
                
                let type = tUrl[..<typeEndIndex]
                jumpToSection(type: String(type), in_url: String(in_url))
            }
        }
    }
    func jumpToSection(type:String,in_url:String){
        switch(type){
        case "forum":
            self.performSegue(withIdentifier: "ForumConnector", sender: in_url)
            break
        case "wiki":
            self.performSegue(withIdentifier: "showWiki", sender: in_url)
            break
        case "ic":
            self.performSegue(withIdentifier: "showICNews", sender: in_url)
            break
        case "alumni":
            self.performSegue(withIdentifier: "showAlumni", sender: in_url)
            break
        case "media","live","video":
            self.performSegue(withIdentifier: "showMedia", sender: self)
            break
        case "weather":
            self.performSegue(withIdentifier: "showWeather", sender: self)
            break
        case "game":
            self.performSegue(withIdentifier: "showGame", sender: self)
            break
        default:
            print(type)
            break
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showWiki"){
            let dest = segue.destination as! WikiViewController
            if(sender as? String != nil){
                dest.in_url = sender as! String
            }
        } else if (segue.identifier == "ForumConnector"){
            let dest = segue.destination as! ForumViewer
            if(sender as? String != nil){
                dest.in_url = sender as! String
            }
        } else if (segue.identifier == "showICNews"){
            let dest = segue.destination as! ICNewsViewController
            if(sender as? String != nil){
                dest.in_url = sender as! String
            }
        } else if (segue.identifier == "showAlumni"){
            let dest = segue.destination as! AlumniRootViewController
            if(sender as? String != nil){
                dest.in_url = sender as! String
            }
        }
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

extension String {
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
}
