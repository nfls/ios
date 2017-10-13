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
    
    
    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
        showCloseButton: false
    ))
    
    required init?(coder aDecoder: NSCoder) {
        let theme = ThemeManager()
        var barColors = [UIColor]()
        let images = ["resources","game","alumni","ic","forum","wiki","media","weather"]
        var barImages = [UIImage]()
        for image in images{
            barImages.append(UIImage(named: image+".png")!)
        }
        for _ in 1...8 {
            barColors.append(theme.normalTheme.titleBackgroundColor!)
        }
        bar = FrostedSidebar(itemImages: barImages, colors: barColors, selectionStyle: .single)
        super.init(coder: aDecoder)
    }
    
    func setUpBars(){
        let theme = ThemeManager()
        var barColors = [UIColor]()
        let images = ["resources","game","alumni","ic","forum","wiki","media","weather"]
        var barImages = [UIImage]()
        for image in images{
            barImages.append(UIImage(named: image+".png")!)
        }
        for _ in 1...8 {
            barColors.append(theme.normalTheme.titleBackgroundColor!)
        }
        self.bar = FrostedSidebar(itemImages: barImages, colors: barColors, selectionStyle: .single)
        self.bar.actionForIndex[4] = {
            self.performSegue(withIdentifier: "showForum", sender: self)
        }
        self.bar.actionForIndex[5] = {
            self.performSegue(withIdentifier: "showWiki", sender: self)
        }
        self.bar.actionForIndex[0] = {
            self.performSegue(withIdentifier: "showResources", sender: self)
        }
        self.bar.actionForIndex[2] = {
            self.performSegue(withIdentifier: "showAlumni", sender: self)
        }
        self.bar.actionForIndex[7] = {
            self.performSegue(withIdentifier: "showWeather", sender: self)
        }
        self.bar.actionForIndex[3] = {
            self.performSegue(withIdentifier: "showIC", sender: self)
        }
        self.bar.actionForIndex[6] = {
            self.performSegue(withIdentifier: "showMedia", sender: self)
        }
        self.bar.actionForIndex[1] = {
            self.performSegue(withIdentifier: "showGame", sender: self)
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
    
    func setUpUI(){
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        let theme = ThemeManager()
        self.navigationController?.navigationBar.barStyle = theme.normalTheme.style
        self.navigationController?.navigationBar.barTintColor = theme.normalTheme.titleBackgroundColor
        self.navigationController?.navigationBar.tintColor = theme.normalTheme.titleButtonColor
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:theme.normalTheme.titleButtonColor ?? UIColor.black]
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.foregroundColor: theme.normalTheme.titleButtonColor ?? UIColor.black
            ]
        }
        setUpBars()
        self.bar.itemBackgroundColor = theme.normalTheme.titleBackgroundColor!
    }
    
    override func viewDidLoad() {
        setUpUI()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setUpUI()
        self.navigationItem.title = "南外人"
        internalHandler(url: handleUrl)
    }
    
    func requestPermission(){
        print("entered")
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
        permision.request { (status) in
            print("requested")
            dump(status)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
        self.navigationItem.title = nil
        //self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func loadNews(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/news",headers: headers).responseJSON { response in
            switch(response.result){
            case .success(let json):
                self.names.removeAll()
                self.subtitles.removeAll()
                self.descriptions.removeAll()
                self.urls.removeAll()
                self.images.removeAll()
                let info = ((json as! [String:AnyObject])["info"] as! [[String:Any]])
                for detail in info {
                    self.names.append(detail["title"] as! String)
                    self.subtitles.append((detail["type"] as! String) + " " + (detail["time"] as! String))
                    self.descriptions.append(detail["detail"] as! String)
                    self.urls.append(detail["conf"] as? String ?? "")
                    self.images.append(URL(string: detail["img"] as! String)!)
                }
                self.tableView.reloadData()
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
            //print("removeError")
        }
        
    }
    
    @objc func settings() {
        self.performSegue(withIdentifier: "showSettings", sender: self)
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
                    /*
                     let application = UIApplication.shared
                     let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
                     let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
                     application.registerUserNotificationSettings(pushNotificationSettings)
                     application.registerForRemoteNotifications()
                     */
                    if let username = UserDefaults.standard.value(forKey: "username") as? String{
                        self.navigationItem.prompt = "Welcome back, " + username
                    } else {
                        self.navigationItem.prompt = "Welcome to NFLS.IO"
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        self.navigationItem.prompt = nil
                        self.navigationController?.navigationBar.setNeedsLayout()
                        self.navigationController?.navigationBar.layoutIfNeeded()
                        self.navigationController?.navigationBar.setNeedsDisplay()
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
        if(url == "logout"){
            checkStatus()
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
        sidebar.dismissAnimated(true, completion: nil
        )
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
