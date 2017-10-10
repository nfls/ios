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
import SCLAlertView
class NewsCell:UITableViewCell{
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var subtitle: UILabel!
}
class NewsViewController:UITableViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver,FrostedSidebarDelegate{
    
    var names = [String]()
    var subtitles = [String]()
    var descriptions = [String]()
    var urls = [String]()
    var images = [String]()
    var pictures = [Data]()
    
    let barImages = [UIImage(named:"forum.png"),UIImage(named:"wiki.png"),UIImage(named:"resources.png"),UIImage(named:"alumni.png"),UIImage(named:"weather.png"),UIImage(named:"ib-world-school-logo-2-colour-rev.png"),UIImage(named:"media.png"),UIImage(named:"games.png")]
    let barColors = [UIColor.orange,UIColor.orange,UIColor.orange,UIColor.orange,UIColor.orange,UIColor.orange,UIColor.orange,UIColor.orange]
    let bar:FrostedSidebar
    
    var productID = ""
    var handleUrl = ""
    var productsRequest = SKProductsRequest()
    var transactionInProgress = false
    var productsArray = [SKProduct]()
    
    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
        showCloseButton: false
    ))
    
    
    required init?(coder aDecoder: NSCoder) {
        bar = FrostedSidebar(itemImages: barImages as! [UIImage], colors: barColors, selectionStyle: .single)
        super.init(coder: aDecoder)
    }
    
    @objc func menu(){
        if(!bar.isCurrentlyOpen){
            bar.showInViewController(self, animated: true)
        }else{
            bar.dismissAnimated(true, completion: nil)
        }
        
        
    }

    override func viewDidLoad() {
        bar.delegate = self
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 92/255, green: 184/255, blue: 92/255, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white // for titles, buttons, etc.
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white
            ]
        }
        Alamofire.request("https://api.nfls.io/weather/ping")
        checkStatus()
        self.navigationItem.title = "Homepage"
        self.removeFile(filename: "", path: "temp")
        let rightButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(self.settings))
        rightButton.icon(from: .FontAwesome, code: "cog", ofSize: 20)
        self.navigationItem.rightBarButtonItem = rightButton
        self.bar.actionForIndex[0] = {
            self.performSegue(withIdentifier: "showForum", sender: self)
        }
        self.bar.actionForIndex[1] = {
            self.performSegue(withIdentifier: "showWiki", sender: self)
        }
        self.bar.actionForIndex[2] = {
            self.performSegue(withIdentifier: "showResources", sender: self)
        }
        self.bar.actionForIndex[3] = {
            self.performSegue(withIdentifier: "showAlumni", sender: self)
        }
        self.bar.actionForIndex[4] = {
            self.performSegue(withIdentifier: "showWeather", sender: self)
        }
        self.bar.actionForIndex[5] = {
            self.performSegue(withIdentifier: "showIC", sender: self)
        }
        self.bar.actionForIndex[6] = {
            self.performSegue(withIdentifier: "showMedia", sender: self)
        }
        self.bar.actionForIndex[7] = {
            self.performSegue(withIdentifier: "showGame", sender: self)
        }
        let leftButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(self.menu))
        leftButton.icon(from: .FontAwesome, code: "users", ofSize: 20)
        self.navigationItem.leftBarButtonItem = leftButton
        
        let productID:NSSet = NSSet(object: "2")
        let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
        tableView.isScrollEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SKPaymentQueue.default().add(self)
        internalHandler(url: handleUrl)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SKPaymentQueue.default().remove(self)
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
            self.checkStatus()
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
                Alamofire.request("https://api.nfls.io/device/purchase", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            case SKPaymentTransactionState.failed:
                print("Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
            default:
                break
            }
        }
    }
    
    func checkStatus(){
        if(UserDefaults.standard.string(forKey: "token") == nil){
            self.showLogin()
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
                    self.showLogin()
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
                                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
                                        showCloseButton: false
                                    ))                                
                                    if(info["push"] as? String != nil && info["push"] as? String != ""){
                                        alert.addButton("Show Details", action: {
                                            let jsonString = info["push"] as! String
                                            let data = jsonString.data(using: .utf8)!
                                            do{
                                                let things = try JSONSerialization.jsonObject(with: data) as! [String:String]
                                                let type = things["type"]!
                                                let in_url = things["url"]!
                                                self.jumpToSection(type: type, in_url: in_url)
                                            } catch {
                                                self.handleUrl = info["push"] as! String
                                                self.internalHandler(url: self.handleUrl)
                                            }
                                        })
                                    }
                                    alert.addButton("Got It", action: {
                                        UIApplication.shared.applicationIconBadgeNumber = 0
                                        UserDefaults.standard.set(id, forKey: "sysmes_id")
                                    })
                                    alert.showInfo(title, subTitle: text)
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
                    self.loadNews()
                    
                    let application = UIApplication.shared
                    let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
                    let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
                    application.registerUserNotificationSettings(pushNotificationSettings)
                    application.registerForRemoteNotifications()
                    if let username = UserDefaults.standard.value(forKey: "username") as? String{
                        self.navigationItem.prompt = "Welcome back, " + username
                    } else {
                        self.navigationItem.prompt = "Welcome to NFLS.IO"
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        self.navigationItem.prompt = nil
                    })
                }
                break
            default:
                SCLAlertView().showNotice("No Internet", subTitle: "Some functions are limited.")
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
    
    func showLogin(info:String? = nil,username:String? = nil,password:String? = nil){
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let _username = alert.addTextField("Username")
        _username.text = username
        let _password = alert.addTextField("Password")
        _password.text = password
        _password.isSecureTextEntry = true
        alert.addButton("Submit") {
            self.login(username: _username.text!, password: _password.text!)
        }
        alert.addButton("Register") {
            self.showRegister()
        }
        alert.addButton("Reset Password") {
            self.showReset()
        }
        alert.showInfo("Login", subTitle: info ?? "")
    }
    func showReset(info:String? = nil,email:String? = nil){
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let username = alert.addTextField("Email")
        username.text = email
        alert.addButton("Submit") {
            self.resetPassword(email: username.text!)
        }
        alert.addButton("Cancel") {
            self.showLogin()
        }
        alert.showInfo("Reset Password", subTitle: info ?? "")
    }
    func resetPassword(email:String){
        let responder = alert.showWait("Loading", subTitle: "Please wait")
        let parameters: Parameters = [
            "email" : email,
            "session" : "app"
        ]
        Alamofire.request("https://api.nfls.io/center/recover", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {
            response in
            responder.close()
            switch(response.result){
            case .success(let json):
                let webStatus = (json as! [String:AnyObject])["code"] as! Int
                if (webStatus == 200){
                    let status = (json as! [String:AnyObject])["info"] as! [String:AnyObject]
                    if(status["status"] as! String == "success"){
                        SCLAlertView().showSuccess("Succeeded", subTitle: "Please check the letter in your email.")
                        self.showLogin()
                    } else {
                        self.showReset(info: (status["message"] as! String), email: email)
                    }
                } else {
                    self.showReset(info: "Something went wrong, please try again later.", email: email)
                }
                break
            default:
                self.showReset(info: "Something went wrong, please try again later.", email: email)
                break
            }
        })
    }
    func showRegister(info:String? = nil,username:String? = nil,email:String? = nil,password:String? = nil,rePassword:String? = nil){
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let _username = alert.addTextField("Username")
        _username.text = username
        let _email = alert.addTextField("Email")
        _email.text = email
        let _password = alert.addTextField("Password")
        _password.isSecureTextEntry = true
        _password.text = password
        let _rePassword = alert.addTextField("Repeat Password")
        _rePassword.isSecureTextEntry = true
        _rePassword.text = rePassword
        alert.addButton("Submit") {
            self.registerAccount(username: _username.text!, password: _password.text!, rePassword: _rePassword.text!, email: _email.text!)
        }
        alert.addButton("Cancel") {
            self.showLogin()
        }
        alert.showInfo("Register", subTitle: info ?? "", closeButtonTitle: "Cancel")
    }
    func registerAccount(username:String,password:String,rePassword:String,email:String){
        if(rePassword != password){
            self.showRegister(info: "Password does not match!", username: username, email: email, password: password, rePassword: rePassword)
        }
        let responder = alert.showWait("Loading", subTitle: "Please wait")
        let parameters: Parameters = [
            "username" : username,
            "password" : password,
            "email" : email,
            "session" : "app"
        ]
        Alamofire.request("https://api.nfls.io/center/register", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {
            response in
            responder.close()
            switch(response.result){
            case .success(let json):
                let webStatus = (json as! [String:AnyObject])["code"] as! Int
                if (webStatus == 200){
                    let status = (json as! [String:AnyObject])["info"] as! [String:AnyObject]
                    if(status["status"] as! String == "success"){
                        SCLAlertView().showSuccess("Succeeded", subTitle: "You can now login.")
                        self.showLogin(info: nil,username: username,password: password)
                    } else {
                        self.showRegister(info: (status["message"] as! String), username: username, email: email, password: password, rePassword: rePassword)
                    }
                } else {
                    self.showRegister(info: "Something went wrong, please try again later.", username: username, email: email, password: password, rePassword: rePassword)
                }
                break
            default:
                self.showRegister(info: "Something went wrong, please try again later.", username: username, email: email, password: password, rePassword: rePassword)
                break
            }
        })
    }
    
    func login(username:String,password:String) {
        let responder = alert.showWait("Loading", subTitle: "Please wait")
        let parameters:Parameters = [
            "username":username,
            "password":password,
            "session":"app"
        ]
        Alamofire.request("https://api.nfls.io/center/login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {
            response in
            responder.close()
            switch(response.result){
            case .success(let json):
                if((json as! [String:AnyObject])["code"] as? Int != 200){
                    self.showLogin(info: "Something went wrong, please try again later.", username: username, password: password)
                } else {
                    let webStatus = (json as! [String:AnyObject])["code"] as! Int
                    if (webStatus == 200){
                        let status = (json as! [String:AnyObject])["info"] as! [String:AnyObject]
                        if(status["status"] as! String == "success"){
                            let token = status["token"]! as! String
                            UserDefaults.standard.set(token, forKey: "token")
                            UserDefaults.standard.synchronize()
                            self.checkStatus()
                        } else {
                            self.showLogin(info: (status["message"] as! String), username: username, password: password)
                        }
                    } else {
                        self.showLogin(info: "Something went wrong, please try again later.", username: username, password: password)
                    }
                }
                break
            default:
                self.showLogin(info: "Something went wrong, please try again later.", username: username, password: password)
                break
            }
        })
    }
    func sidebar(_ sidebar: FrostedSidebar, willShowOnScreenAnimated animated: Bool) {
        return
    }
    
    func sidebar(_ sidebar: FrostedSidebar, didShowOnScreenAnimated animated: Bool) {
        tableView.isScrollEnabled = false
    }
    
    func sidebar(_ sidebar: FrostedSidebar, willDismissFromScreenAnimated animated: Bool) {
        return
    }
    
    func sidebar(_ sidebar: FrostedSidebar, didDismissFromScreenAnimated animated: Bool) {
        tableView.isScrollEnabled = true
    }
    
    func sidebar(_ sidebar: FrostedSidebar, didTapItemAtIndex index: Int) {
        return
    }
    
    func sidebar(_ sidebar: FrostedSidebar, didEnable itemEnabled: Bool, itemAtIndex index: Int) {
        return
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

