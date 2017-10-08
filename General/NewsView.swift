//
//  NewsView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/10/4.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import Alamofire
import FrostedSidebar
import StoreKit

class NewsCell:UITableViewCell{
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var subtitle: UILabel!
}
class NewsViewController:UITableViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver{
    
    var names = [String]()
    var subtitles = [String]()
    var descriptions = [String]()
    var urls = [String]()
    var images = [String]()
    var pictures = [Data]()
    
    let barImages = [UIImage(named:"forum.png")]
    let barColors = [UIColor.orange]
    let bar:FrostedSidebar
    
    var productID = ""
    var handleUrl = ""
    var productsRequest = SKProductsRequest()
    var transactionInProgress = false
    var productsArray = [SKProduct]()
    
    required init?(coder aDecoder: NSCoder) {
        bar = FrostedSidebar(itemImages: barImages as! [UIImage], colors: barColors, selectionStyle: .single)
        super.init(coder: aDecoder)
    }
    
    @objc func menu(){
        bar.showInViewController(self, animated: true)
    }

    override func viewDidLoad() {
        checkStatus()
        loadNews()
        navigationItem.title = "Homepage"
        removeFile(filename: "", path: "temp")
        let rightButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(settings))
        rightButton.icon(from: .FontAwesome, code: "cog", ofSize: 20)
        navigationItem.rightBarButtonItem = rightButton
        bar.actionForIndex[0] = {
            self.performSegue(withIdentifier: "showForum", sender: self)
        }
        
        let leftButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(menu))
        leftButton.icon(from: .FontAwesome, code: "users", ofSize: 20)
        navigationItem.leftBarButtonItem = leftButton
        
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
        if let username = UserDefaults.standard.value(forKey: "username") as? String{
            self.navigationItem.prompt = "Welcome back, " + username
        } else {
            self.navigationItem.prompt = "Welcome to NFLS.IO"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            self.navigationItem.prompt = nil
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        internalHandler(url: handleUrl)
        
    }
    
    func loadNews(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/news",headers: headers).responseJSON { response in
            switch(response.result){
            case .success(let json):
                
                let info = ((json as! [String:AnyObject])["info"] as! [[String:Any]])
                for detail in info {
                    self.names.append(detail["title"] as! String)
                    self.subtitles.append((detail["type"] as! String) + " " + (detail["time"] as! String))
                    self.descriptions.append(detail["detail"] as! String)
                    self.urls.append(detail["conf"] as? String ?? "")
                    self.images.append(detail["img"] as! String)
                }
                self.getPictures(index: 0)
                break
            default:
                break
            }
        }
    }
    
    func getPictures(index:Int){
        if(index >= images.count){
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        Alamofire.request(images[index]).responseData { (response) in
            switch(response.result){
            case .success(let data):
                self.pictures.append(data)
                self.getPictures(index: index + 1)
                break
            default:
                break
            }
        }
    }
    
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "news"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "info", for: indexPath) as! NewsCell
        cell.cellTitle.text = names[indexPath.row]
        cell.subtitle.text = subtitles[indexPath.row]
        cell.detail.text = descriptions[indexPath.row]
        cell.myImage.image = UIImage(data: pictures[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleUrl = urls[indexPath.row]
        internalHandler(url: handleUrl)
        //navigationController?.popViewController(animated: true)
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
            self.performSegue(withIdentifier: "showLicenses", sender: self)
            
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
            self.performSegue(withIdentifier: "showCenter", sender: self)
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
        debugPrint(in_url)
        switch(type){
        case "forum":
            self.performSegue(withIdentifier: "showForum", sender: in_url)
            break
        case "wiki":
            self.performSegue(withIdentifier: "showWiki", sender: in_url)
            break
        case "ic":
            self.performSegue(withIdentifier: "showIC", sender: in_url)
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
        } else if (segue.identifier == "showForum"){
            let dest = segue.destination as! ForumViewer
            if(sender as? String != nil){
                dest.in_url = sender as! String
            }
        } else if (segue.identifier == "showIC"){
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

