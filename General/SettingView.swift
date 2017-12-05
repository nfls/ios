//
//  SettingView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/10/11.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import InAppSettingsKit
import StoreKit
import Alamofire
import PassKit
import SCLAlertView
import ChromaColorPicker
import Toucan
import MobileCoreServices

class ColorCell:UITableViewCell{
    @IBOutlet weak var container:UIView!
    let picker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
}
class VersionCell:UITableViewCell{
    @IBOutlet weak var version:UILabel!
    @IBOutlet weak var codeName:UILabel!
}
class UserCell:UITableViewCell{
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var email: UILabel!
    
}
class SettingViewController:IASKAppSettingsViewController,IASKSettingsDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver,ChromaColorPickerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    var productsRequest = SKProductsRequest()
    var productsArray = [SKProduct]()
    var username:String? = nil
    var email:String? = nil
    var image = UIImageView()
    var img:UIImage? = UIImage()
    
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
            default:
                break
            }
        }
    }
    
    func settingsViewControllerDidEnd(_ sender: IASKAppSettingsViewController!) {
        return
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let productID:NSSet = NSSet(object: "2")
        let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
        requestUsername()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SKPaymentQueue.default().add(self)
    }
    
    func requestUsername(){
        username = UserDefaults.standard.value(forKey: "username") as? String
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/generalInfo", headers: headers).responseJSON{ response in
            switch response.result{
            case .success(let json):
                if(((json as! [String:AnyObject])["code"] as! Int)==200){
                    let jsonDic = (json as! [String:AnyObject])["info"]!
                    self.username = jsonDic.object(forKey: "username") as? String
                    self.email = jsonDic.object(forKey: "email") as? String
                    if let url = jsonDic.object(forKey: "avatar_path") as? String{
                        self.image.kf.setImage(with: URL(string: ("https://forum.nfls.io/assets/avatars/" + url)),completionHandler: {
                            (image, error, cacheType, imageUrl) in
                            self.img = Toucan(image: image!).maskWithEllipse(borderWidth: 3, borderColor: UIColor.gray).image
                            self.tableView.reloadData()
                        })
                    }else{
                        self.image.kf.setImage(with: URL(string: ("https://center.nfls.io/center/js/no_head.png")),completionHandler: {
                            (image, error, cacheType, imageUrl) in
                            self.img = Toucan(image: image!).maskWithEllipse(borderWidth: 3, borderColor: UIColor.gray).image
                            self.tableView.reloadData()
                        })
                    }
                }
            default:
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SKPaymentQueue.default().remove(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    // MARK: picker is not properly reused
    func settingsViewController(_ sender: IASKAppSettingsViewController!, buttonTappedFor specifier: IASKSpecifier!) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch(specifier.key()){
        case "user.avatar":
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeImage as String]
            picker.delegate = self
            self.present(picker,animated: true)
        case "app.blog.hqy":
            (navigationController?.viewControllers[navigationController!.viewControllers.count - 3] as! NewsViewController).handleUrl = "https://hqy.moe/#blog"
            navigationController?.popViewController(animated: true)
            navigationController?.popViewController(animated: true)
            break
        case "app.blog.xzd":
            (navigationController?.viewControllers[navigationController!.viewControllers.count - 3] as! NewsViewController).handleUrl = "https://xzd.nfls.io/#blog"
            navigationController?.popViewController(animated: true)
            navigationController?.popViewController(animated: true)
            break
        case "app.blog.mr":
            (navigationController?.viewControllers[navigationController!.viewControllers.count - 3] as! NewsViewController).handleUrl = "https://mrtunnel.club"
            navigationController?.popViewController(animated: true)
            navigationController?.popViewController(animated: true)
            break
        case "app.blog.mrtunnel":
            (navigationController?.viewControllers[navigationController!.viewControllers.count - 3] as! NewsViewController).handleUrl = "https://blog.mrtunnel.club"
            navigationController?.popViewController(animated: true)
            navigationController?.popViewController(animated: true)
            break
        case "app.about":
            (navigationController?.viewControllers[navigationController!.viewControllers.count - 3] as! NewsViewController).handleUrl = "https://wiki.nfls.io/w/%E5%85%B3%E4%BA%8E%E6%88%91%E4%BB%AC"
            navigationController?.popViewController(animated: true)
            navigationController?.popViewController(animated: true)
            break
        case "app.license":
            let viewController = storyboard.instantiateViewController(withIdentifier :"license") as! OpenSourceLicenseViewController
            navigationController?.pushViewController(viewController, animated: true)
            break
        case "app.donate":
            if(!self.productsArray.isEmpty){
                let payment = SKPayment(product: self.productsArray[0] as SKProduct)
                SKPaymentQueue.default().add(payment)
            }
            break
        case "app.realname":
            (navigationController?.viewControllers[navigationController!.viewControllers.count - 2] as! NewsViewController).handleUrl = "realname"
            navigationController?.popViewController(animated: true)
            break
        case "app.ticket":
            let headers: HTTPHeaders = [
                "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
            ]
            Alamofire.request("https://api.nfls.io/ic/ticket", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData(completionHandler: { (response) in
                if(response.response?.statusCode != 200){
                    SCLAlertView().showError("错误", subTitle: "您的账户下暂时没有可用的入场券")
                    return
                }
                switch(response.result){
                case .success(let data):
                    let pass = PKPass(data: data, error: nil)
                    let passview = PKAddPassesViewController(pass: pass)
                    SCLAlertView().showInfo("检测到可用门票", subTitle: "请在下面的窗口中选择“添加”，之后，您可以在系统自带的Wallet应用中查看该门票").setDismissBlock {
                        self.present(passview, animated:true)
                    }
                    //self.navigationController?.pushViewController(passview, animated: true)
                default:
                    SCLAlertView().showError("错误", subTitle: "您的账户下暂时没有可用的入场券")
                }
            })
            break
        case "settings.theme.pick":
            let dialog = SCLAlertView()
            let color:[String:String] = [
                "少女粉":"pink",
                "香芋紫":"purple",
                "蓝绿色":"blueGreen",
                "薄荷绿":"mintGreen",
                "青草绿":"grass",
                "雾霾蓝":"fogBlue",
                "瞎眼睛":"kill"
            ]
            for(key,value)in color{
                dialog.addButton(key, action: {
                    UserDefaults.standard.set(value, forKey: "settings.theme")
                })
            }
            dialog.showInfo("预设主题", subTitle: "您可在此选择内置的预设主题", closeButtonTitle: "取消")
            break
        case "app.review":
            rateApp(appId: "id1246252649") { success in
                print("RateApp \(success)")
            }
            break
        case "user.email":
            self.editPassword()
            break
        case "user.username":
            self.editUsername()
            break
        case "user.clean":
            let logout = SCLAlertView()
            logout.addButton("仅退出", action: {
                self.logout()
            })
            logout.addButton("退出并清除所有在线设备", action: {
                self.logoutAll()
            })
            logout.showNotice("退出", subTitle: "请选择您的操作",closeButtonTitle: "取消")
            break
        case "user.message":
            let viewController = storyboard.instantiateViewController(withIdentifier :"message") as! NotificationViewController
            navigationController?.pushViewController(viewController, animated: true)
            //self.performSegue(withIdentifier: "showMessage", sender: self)
            break
        default:
            break
        }
    }
    
    func settingsViewController(_ sender: IASKAppSettingsViewController!, tableView: UITableView!, didSelectCustomViewSpecifier specifier: IASKSpecifier!) {
        switch(specifier.key()){
        
        case "settings.user":
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"info") as! GeneralInfoView
            navigationController?.pushViewController(viewController, animated: true)
            //self.performSegue(withIdentifier: "showInfo", sender: self)
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView!, cellFor specifier: IASKSpecifier!) -> UITableViewCell! {
        switch(specifier.key()){
        case "settings.theme.customize":
            let cell = tableView.dequeueReusableCell(withIdentifier: "color") as! ColorCell
            let container = cell.container!
            cell.backgroundColor = UIColor.gray
            container.backgroundColor = UIColor.gray
            
            cell.picker.delegate = self
            cell.picker.padding = 5
            cell.picker.stroke = 3
            if let color = UserDefaults.standard.colorForKey(key: "settings.theme.color"){
                cell.picker.adjustToColor(color)
            }
            //picker.addButton.isHidden = true
            cell.container.addSubview(cell.picker)
            cell.picker.layout()
            return cell
        case "settings.version":
            let cell = tableView.dequeueReusableCell(withIdentifier: "version") as! VersionCell
            let dictionary = Bundle.main.infoDictionary!
            
            let version = dictionary["CFBundleShortVersionString"] as! String
            let build = dictionary["CFBundleVersion"] as! String
            let codeNameCN = dictionary["CodeNameCN"] as! String
            let codeNameEN = dictionary["CodeNameEN"] as! String
            
            cell.version.text = "Version " + version + " Build " + build
            cell.codeName.text = codeNameEN + " 「" + codeNameCN + "」"
            return cell
        case "settings.user":
            let cell = tableView.dequeueReusableCell(withIdentifier: "user") as! UserCell
            cell.email.text = email
            cell.username.text = username
            cell.avatar.image = img
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    func tableView(_ tableView: UITableView!, heightFor specifier: IASKSpecifier!) -> CGFloat {
        switch(specifier.key()){
        case "settings.theme.customize":
            return 230
        case "settings.version":
            return 50
        case "settings.user":
            return 100
        default:
            return 82
        }
    }
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId + "?action=write-review") else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        UserDefaults.standard.setColor(color: color, forKey: "settings.theme.color")
        UserDefaults.standard.set("customize", forKey: "settings.theme")
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: false)
        let responder = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
            showCloseButton: false
        )).showWait("请稍后", subTitle: "上传中")
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        var id:Int = 0
        Alamofire.request("https://api.nfls.io/center/generalInfo", headers: headers).responseJSON{ response in
            switch response.result{
            case .success(let json):
                if(((json as! [String:AnyObject])["code"] as! Int)==200){
                    let jsonDic = (json as! [String:AnyObject])["info"]!
                    id = jsonDic.object(forKey: "id") as! Int
                    Alamofire.upload(multipartFormData: { data in
                        data.append(UIImagePNGRepresentation(Toucan(image: image).resize(CGSize(width: 200, height: 200), fitMode: Toucan.Resize.FitMode.clip).image!)!, withName: "avatar", fileName: "avatar.png", mimeType: "image/png")
                    }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: "https://forum.nfls.io/api/users/" + String(describing: id) + "/avatar", method: .post, headers: headers, encodingCompletion: { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                            self.requestUsername()
                            responder.close()
                        })
                        
                    })
                }
            default:
                break
            }
        }
    }
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        let codeNameCN = dictionary["CodeNameCN"] as! String
        let codeNameEN = dictionary["CodeNameEN"] as! String
        SCLAlertView().showNotice("关于", subTitle: "南外人 v\(version)(\(build))[\(codeNameCN)/\(codeNameEN)]，更多信息请在下方关于的开发组内查看。")
        
    }
    
    func logout(){
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
        (navigationController?.viewControllers[navigationController!.viewControllers.count - 2] as! NewsViewController).handleUrl = "logout"
        navigationController?.popViewController(animated: true)
    }
    func logoutAll(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/regenToken",headers: headers).responseJSON(completionHandler: { (response) in
            (self.navigationController?.viewControllers[self.navigationController!.viewControllers.count - 2] as! NewsViewController).handleUrl = "logout"
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func editUsername(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/card", headers:headers).responseJSON(completionHandler: { (response) in
            switch(response.result){
            case .success(let json):
                let count = ((json as! [String:AnyObject])["info"] as! [String:Int])["rename_cards"]!
                let check = UIAlertController(title: "改名", message: "此处您可以修改您的用户名，长度3-16位，支持中英日文，您目前拥有 " + String(describing: count) + "张改名卡。", preferredStyle: .alert)
                let back = UIAlertAction(title: "返回", style: .cancel, handler: nil)
                let change = UIAlertAction(title: "使用", style: .default, handler: {
                    action in
                    let action = UIAlertController(title: "请输入", message: "请输入您的新的用户名，确认后，请至个人信息页面查询是否修改成功，未修改则说明不符合要求或者是与他人重复。", preferredStyle: .alert)
                    action.addTextField(configurationHandler: { (textfield) in
                        textfield.placeholder = "用户名"
                    })
                    let ok = UIAlertAction(title: "确认", style: .default, handler: { (alert) in
                        let parameters:Parameters = [
                            "name": action.textFields![0].text ?? ""
                        ]
                        Alamofire.request("https://api.nfls.io/center/rename", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {_ in })
                    })
                    let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                    action.addAction(ok)
                    action.addAction(cancel)
                    self.present(action,animated: true)
                })
                check.addAction(back)
                if(count > 0){
                    check.addAction(change)
                }
                self.present(check, animated: true)
                break
            default:
                break
            }
        })
    }
    
    func editPassword(){
        (self.navigationController?.viewControllers[(self.navigationController!.viewControllers.count) - 2] as! NewsViewController).handleUrl = "https://forum.nfls.io/settings"
        self.navigationController?.popViewController(animated: true)
    }
    /*
    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "预设", style: .plain, target: self, action: #selector(selectColor))
        view.backgroundColor = UIColor.gray
     
        SCLAlertView().showInfo("说明", subTitle: "您可在此选择内置或自定义您的App主题。如果您希望选择预设主题，请点按右上角预设按钮；如果您希望自定义主题，请使用下方的调色盘选择您喜爱的颜色，并按+号确认。", closeButtonTitle: "我知道了" )
    }
    */
    
    
}
