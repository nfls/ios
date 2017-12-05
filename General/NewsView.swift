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
import SCLAlertView
import Permission
import StoreKit
import SafariServices

class NewsCell:UITableViewCell{
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var subtitle: UILabel!
}
class NewsViewController:UITableViewController,FrostedSidebarDelegate{
    
    var names = [String]()
    var subtitles = [String]()
    var descriptions = [String]()
    var urls = [String]()
    var images = [URL]()
    
    var bar:FrostedSidebar
    var productID = ""
    var handleUrl = ""
    var transactionInProgress = false
    var setView:SettingViewController
    
    
    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
        showCloseButton: false
    ))
    
    required init?(coder aDecoder: NSCoder) {
        let images = ["resources","game","photo","alumni","ic","forum","wiki","media","weather"]
        var barImages = [UIImage]()
        for image in images{
            barImages.append(UIImage(named: image+".png")!)
        }
        bar = FrostedSidebar(itemImages: barImages, colors: nil, selectionStyle: .single)
        setView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settings") as! SettingViewController
        super.init(coder: aDecoder)
    }
    
    func setUpBars(){
        self.bar.actionForIndex[0] = {
            self.getAuthStatus(checkIC: true, segueName: "showResources")
        }
        self.bar.actionForIndex[1] = {
            self.performSegue(withIdentifier: "showGame", sender: self)
        }
        self.bar.actionForIndex[2] = {
            self.performSegue(withIdentifier: "showPhoto", sender: self)
        }
        self.bar.actionForIndex[3] = {
            self.performSegue(withIdentifier: "showAlumni", sender: self)
        }
        self.bar.actionForIndex[4] = {
            self.performSegue(withIdentifier: "showIC", sender: self)
        }
        self.bar.actionForIndex[5] = {
            self.performSegue(withIdentifier: "showForum", sender: self)
        }
        self.bar.actionForIndex[6] = {
            self.performSegue(withIdentifier: "showWiki", sender: self)
        }
        self.bar.actionForIndex[7] = {
            self.performSegue(withIdentifier: "showMedia", sender: self)
        }
        self.bar.actionForIndex[8] = {
            self.performSegue(withIdentifier: "showWeather", sender: self)
        }
        
        self.bar.delegate = self
        
    }
    
    @objc func menu(){
        if(!bar.isCurrentlyOpen){
            bar.showInViewController(self, animated: true)
        }else{
            bar.dismissAnimated(true, completion: nil)
        }
    }
    @objc func gestureMenu(){
        if(!bar.isCurrentlyOpen){
            bar.showInViewController(self, animated: true)
        }
    }
    @objc func closeGestureMenu(){
        if(bar.isCurrentlyOpen){
            bar.dismissAnimated(true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        setUpBars()
        Alamofire.request("https://api.nfls.io/weather/ping")
        checkStatus()
        self.removeFile(filename: "", path: "temp")
        let rightButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(self.settings))
        rightButton.icon(from: .FontAwesome, code: "cog", ofSize: 20)
        self.navigationItem.rightBarButtonItem = rightButton
        let leftButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(self.menu))
        leftButton.icon(from: .FontAwesome, code: "users", ofSize: 20)
        self.navigationItem.leftBarButtonItem = leftButton
        
        let edgePan = UISwipeGestureRecognizer(target: self, action: #selector(gestureMenu))
        edgePan.direction = .right
        view.addGestureRecognizer(edgePan)
        
        let swipeBack = UISwipeGestureRecognizer(target: self, action: #selector(closeGestureMenu))
        swipeBack.direction = .left
        view.addGestureRecognizer(swipeBack)
        
    }
    
    @objc func refresh() {
        loadNews()
        debugPrint("refresh")
        // Code to refresh table view
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //setUpUI()
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        self.bar.itemBackgroundColor = (navigationController?.navigationBar.barTintColor)!
        self.navigationItem.title = "南外人"
        if let url = (UIApplication.shared.delegate as! AppDelegate).url {
            (UIApplication.shared.delegate as! AppDelegate).url = nil
            handleUrl = url
        }
        internalHandler(url: handleUrl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if #available(iOS 11.0, *) {
            //self.navigationController?.prefersLargeTitles = true
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        tableView.setContentOffset(CGPoint.zero, animated: true)
        self.loadNews()
        super.viewWillAppear(animated)
    }
    
    
    func requestPermission(){
        let permision:Permission = .notifications
        let alert = permision.prePermissionAlert
        alert.title = "权限请求"
        alert.message = "为了确保收到最新的活动通知，请允许我们给您发送推送消息"
        alert.cancel = "取消"
        alert.confirm = "好的"
        let denied = permision.deniedAlert
        denied.title = "缺少权限"
        denied.message = "您没有开启推送权限，我们无法给您发送最新的活动通知"
        denied.settings = "设置"
        denied.cancel = "取消"
        let disabled = permision.disabledAlert
        disabled.title = "缺少权限"
        disabled.message = "您没有开启推送权限，我们无法给您发送最新的活动通知"
        disabled.settings = "设置"
        disabled.cancel = "取消"
        
        permision.presentPrePermissionAlert = true
        if var time = (UserDefaults.standard.object(forKey: "date.last") as? Date){
            time.addTimeInterval(60*60*24*7)
            if(time > Date()){
                permision.presentDisabledAlert = false
                permision.presentDeniedAlert = false
            }else{
                permision.presentDisabledAlert = true
                permision.presentDeniedAlert = true
            }
        }else{
            permision.presentDisabledAlert = true
            permision.presentDeniedAlert = true
        }
        
        
        permision.request { (status) in
            switch(status){
            case .authorized:
                let application = UIApplication.shared
                let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
                let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
                application.registerUserNotificationSettings(pushNotificationSettings)
                application.registerForRemoteNotifications()
                break
            default:
                UserDefaults.standard.set(Date(), forKey: "date.last")
                break
            }
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = nil
        //self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func loadNews(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + (UserDefaults.standard.string(forKey: "token") ?? "")
        ]
        Alamofire.request("https://api.nfls.io/center/news",headers: headers).responseJSON { response in
            switch(response.result){
            case .success(let json):
                self.names.removeAll()
                self.subtitles.removeAll()
                self.descriptions.removeAll()
                self.urls.removeAll()
                self.images.removeAll()
                if let info = (json as! [String:AnyObject])["info"] as? [[String:Any]] {
                    for detail in info {
                        self.names.append(detail["title"] as! String)
                        self.subtitles.append((detail["type"] as! String) + " " + (detail["time"] as! String))
                        self.descriptions.append(detail["detail"] as! String)
                        self.urls.append(detail["conf"] as? String ?? "")
                        self.images.append(URL(string: detail["img"] as! String)!)
                    }
                    self.tableView.reloadData()
                    if self.refreshControl?.isRefreshing == true {
                        self.refreshControl?.endRefreshing()
                    }
                }
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
        cell.myImage!.kf.setImage(with: images[indexPath.row])
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
            //print("Error")
        }
        
    }
    
    @objc func settings() {
        self.bar.dismissAnimated(true, completion: nil)
        self.navigationController?.pushViewController(setView, animated: true)
        //self.performSegue(withIdentifier: "showSettings", sender: self)
    }
    
    func checkStatus(){
        checkUpdate()
        if(UserDefaults.standard.string(forKey: "token") == nil){
            self.showLogin()
            return
        }
        let headers: HTTPHeaders =
            [
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
                    self.getAuthStatus()
                    self.getBadge()
                    self.requestMessage()
                    self.requestUsername()
                    //self.loadNews()
                    self.requestReview()
                }
                break
            default:
                SCLAlertView().showNotice("No Internet", subTitle: "Some functions are limited.")
                break
            }
            
        })
    }
    func requestUsername(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
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
    func requestMessage(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/last",headers: headers).responseJSON(completionHandler: {
            response in
            switch response.result{
            case .success(let json):
                if((json as! [String:AnyObject])["code"]! as! Int == 200){
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
                                    self.jumpToSection(type: type, in_url: in_url, realurl: nil)
                                } catch {
                                    self.handleUrl = info["push"] as! String
                                    self.internalHandler(url: self.handleUrl)
                                }
                            })
                        }
                        alert.addButton("Got It", action: {
                            UIApplication.shared.applicationIconBadgeNumber = 0
                            UserDefaults.standard.set(id, forKey: "sysmes_id")
                            self.requestPermission()
                        })
                        alert.showInfo(title, subTitle: text)
                    }else{
                        self.requestPermission()
                    }
                }
                break
            default:
                break
            }
        })
    }
    func internalHandler(url:String){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        handleUrl = ""
        if(url == "logout"){
            checkStatus()
            return
        }else if (url == "realname"){
            getAuthStatus(checkIC: true)
            return
        }
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
                jumpToSection(type: String(type), in_url: String(in_url), realurl:URL(string: url))
            }
        }else{
            if let realUrl = URL(string: url){
                let safari = SFSafariViewController(url: realUrl)
                self.present(safari, animated: true, completion: nil)
            }
        }
    }
    func jumpToSection(type:String,in_url:String,realurl:URL?){
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
            if let url = realurl{
                let safari = SFSafariViewController(url: url)
                self.present(safari, animated: true, completion: nil)
            }
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
        UserDefaults.standard.set(Date(), forKey: "date.request")
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
                        self.showLogin(info: "You registered successfully, and now you can login" ,username: username,password: password)
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
                            UserDefaults.standard.set(true, forKey: "settings.keep.enabled")
                            UserDefaults.standard.set(true, forKey: "settings.night.auto")
                            //UserDefaults.standard.synchronize()
                            self.checkStatus()
                            self.loadNews()
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
        sidebar.dismissAnimated(true, completion: nil
        )
    }
    
    func sidebar(_ sidebar: FrostedSidebar, didEnable itemEnabled: Bool, itemAtIndex index: Int) {
        return
    }
    
    enum AuthStatus{
        case phoneNumber
        case phoneCode
        case identity
    }
    func getAuthStatus(checkIC:Bool = false,segueName:String? = nil){
        if(NetworkReachabilityManager()!.isReachable){
            Alamofire.request("https://api.nfls.io/center/auth?token="+UserDefaults.standard.string(forKey: "token")!).responseJSON { (response) in
                switch(response.result){
                case .success(let json):
                    let data = (json as! [String:AnyObject])["info"] as! [String:Bool]
                    if(!data["phone"]! && (checkIC || UserDefaults.standard.value(forKey: "app.notified") == nil)){
                        self.realnameAuth(withStep: .phoneNumber)
                    }else if(!data["ic"]! && checkIC){
                        self.realnameAuth(withStep: .identity)
                    }else{
                        if let name = segueName {
                            self.performSegue(withIdentifier: name, sender: self)
                        }else if checkIC{
                            self.realnameAuth(withStep: .identity)
                        }
                    }
                default:
                    if let name = segueName {
                        self.performSegue(withIdentifier: name, sender: self)
                    }
                    break
                }
            }
        }else{
            if let name = segueName {
                self.performSegue(withIdentifier: name, sender: self)
            }
        }
       
    }
    var phoneText = ""
    func realnameAuth(withStep step:AuthStatus,info:AnyObject? = nil){
        let message = SCLAlertView()
        switch(step){
        case .phoneNumber:
            let phoneNumber = message.addTextField("手机号")
            message.addButton("提交", action: {
                let responder = self.alert.showWait("提交中", subTitle: "请稍后")
                let headers: HTTPHeaders = [
                    "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
                ]
                let parameters: Parameters = [
                    "phone": phoneNumber.text!,
                    "captcha":"app"
                ]
                Alamofire.request("https://api.nfls.io/center/phone", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
                    responder.close()
                    switch(response.result){
                    case .failure(_):

                        break
                    case .success(let json):
                        if((json as! [String:AnyObject])["code"] as! Int == 200){
                            self.phoneText = phoneNumber.text!
                            self.realnameAuth(withStep: .phoneCode)
                        }else{
                            SCLAlertView().showEdit("错误", subTitle: "手机号无效", closeButtonTitle: "重试").setDismissBlock {
                                self.realnameAuth(withStep: .phoneNumber)
                            }
                        }
                        
                        break
                    }
                })
            })
            message.showInfo("手机号验证", subTitle: "根据网信办相关规定，在使用本站服务前，您需要绑定您的手机号并提交相关信息。", closeButtonTitle: "跳过")
            UserDefaults.standard.set(true, forKey: "app.notified")
            break
        case .phoneCode:
            let code = message.addTextField("6位验证码")
            message.addButton("提交", action: {
                let responder = self.alert.showWait("提交中", subTitle: "请稍后")
                let headers: HTTPHeaders = [
                    "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
                ]
                let parameters: Parameters = [
                    "phone": self.phoneText,
                    "code": code.text!,
                    "captcha":"app"
                ]
                Alamofire.request("https://api.nfls.io/center/phone", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
                    responder.close()
                    switch(response.result){
                    case .failure(_):
                        SCLAlertView().showError("错误", subTitle: "验证码无效").setDismissBlock {
                            self.realnameAuth(withStep: .phoneCode)
                        }
                        break
                    case .success(let json):
                        if((json as! [String:AnyObject])["code"] as! Int == 200){
                            SCLAlertView().showSuccess("成功", subTitle: "您已成功绑定您的手机，如果您不是国际部在校学生，可跳过下一步", closeButtonTitle: "继续").setDismissBlock {
                                self.realnameAuth(withStep: .identity)
                            }
                            self.phoneText = ""
                        }else{
                            SCLAlertView().showEdit("错误", subTitle: "6位数验证码无效", closeButtonTitle: "重试").setDismissBlock {
                                self.realnameAuth(withStep: .phoneCode)
                            }
                        }
                        
                        break
                    }
                })
            })
            message.showInfo("手机号验证", subTitle: "请输入短信中的6位验证码", closeButtonTitle: "取消")
            break
        case .identity:
            let chnName = message.addTextField("中文名")
            let engName = message.addTextField("英文名")
            let tmpClass = message.addTextField("班级")
            let headers: HTTPHeaders = [
                "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
            ]
            message.addButton("提交", action: {
                let responder = self.alert.showWait("提交中", subTitle: "请稍后")
                let parameters:Parameters = [
                    "chnName":chnName.text ?? "",
                    "engName":engName.text ?? "",
                    "tmpClass":tmpClass.text ?? "",
                    
                ]
                Alamofire.request("https://api.nfls.io/center/realname", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
                    responder.close()
                    switch(response.result){
                    case .success(_):
                        SCLAlertView().showSuccess("成功", subTitle: "您已成功提交！如需要修改，请在设置中点击相关选项")
                        break
                    case .failure(_):
                        SCLAlertView().showError("错误", subTitle: "提交错误，请重试").setDismissBlock {
                            self.realnameAuth(withStep: .identity)
                        }
                    }
                })
            })
            Alamofire.request("https://api.nfls.io/center/realname", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
                switch(response.result){
                case .success(let json):
                    let data = (json as! [String:AnyObject])["info"] as! [String:Any]
                    chnName.text = data["chnName"]! as? String
                    engName.text = data["engName"]! as? String
                    tmpClass.text = data["tmpClass"]! as? String
                    var msg = ""
                    if(data["enabled"]! as! Bool){
                        msg = "当前状态：已通过（所有功能可正常使用，不可修改）"
                    }else if(data["submitted"]! as! Bool){
                        msg = "当前状态：已提交，待审核（所有功能可正常使用，可以修改）"
                    }else{
                        msg = "当前状态：未提交（无法访问往卷下载）"
                    }
                    message.showInfo("个人信息认证", subTitle: "请在下面填写您的班级信息以启用资源下载功能，注意：恶意填写将导致封号；非国际部在校学生可跳过该步骤，您已完成所有基础认证项目。" + msg, closeButtonTitle: "返回")
                    break
                case .failure(_):
                    break
                }
            })
            
            break
            
        }
    }
    
    
    func checkUpdate(){
        let parameters:Parameters = [
            "version":Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        ]
        Alamofire.request("https://api.nfls.io/device/update", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {
            response in
            switch(response.result){
            case .success(let json):
                let code = (json as! [String:Int])["code"]
                if(code == 201){
                    SCLAlertView().showInfo("检测到更新", subTitle: "请在App Store中下载最新更新")
                } else if (code == 202) {
                    SCLAlertView(appearance: SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )).showInfo("不受支持的App版本", subTitle: "服务器已不再支持您的App版本，请考虑升级")
                }
            default:
                break
            }
            
        })
    }
    
    func requestReview(){
        if #available(iOS 10.3, *) {
            if var time = (UserDefaults.standard.object(forKey: "date.request") as? Date){
                time.addTimeInterval(60*60*24*14)
                if(time <= Date()){
                    UserDefaults.standard.set(Date(), forKey: "date.request")
                    SKStoreReviewController.requestReview()
                }
            }else{
                UserDefaults.standard.set(Date(), forKey: "date.request")
                SKStoreReviewController.requestReview()
            }
            
        }
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
extension UIImage {
    
    func tint(with color: UIColor) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        // flip the image
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -self.size.height)
        
        // multiply blend mode
        context.setBlendMode(.multiply)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context.fill(rect)
        
        // create UIImage
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
