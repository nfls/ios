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

class ColorCell:UITableViewCell{
    @IBOutlet weak var container:UIView!
}
class VersionCell:UITableViewCell{
    @IBOutlet weak var version:UILabel!
    @IBOutlet weak var codeName:UILabel!
}
class SettingViewController:IASKAppSettingsViewController,IASKSettingsDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver,ChromaColorPickerDelegate{
    
    var productsRequest = SKProductsRequest()
    var productsArray = [SKProduct]()
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SKPaymentQueue.default().add(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SKPaymentQueue.default().remove(self)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func settingsViewController(_ sender: IASKAppSettingsViewController!, buttonTappedFor specifier: IASKSpecifier!) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch(specifier.key()){
        case "app.blog.hqy":
            (navigationController?.viewControllers[navigationController!.viewControllers.count - 2] as! NewsViewController).handleUrl = "https://hqy.moe"
            navigationController?.popViewController(animated: true)
            break
        case "app.blog.xzd":
            (navigationController?.viewControllers[navigationController!.viewControllers.count - 2] as! NewsViewController).handleUrl = "https://xzd.nfls.io"
            navigationController?.popViewController(animated: true)
            break
        case "app.license":
            let viewController = storyboard.instantiateViewController(withIdentifier :"license") as! OpenSourceLicenseViewController
            navigationController?.pushViewController(viewController, animated: true)
            break
        case "app.user":
            let viewController = storyboard.instantiateViewController(withIdentifier :"user") as! CenterTabRootViewController
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
        case "app.logout":
            if let bundle = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundle)
            }
            (navigationController?.viewControllers[navigationController!.viewControllers.count - 2] as! NewsViewController).handleUrl = "logout"
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
            let picker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            picker.delegate = self
            picker.padding = 5
            picker.stroke = 3
            if let color = UserDefaults.standard.colorForKey(key: "settings.theme.color"){
                picker.adjustToColor(color)
            }
            //picker.addButton.isHidden = true
            container.addSubview(picker)
            picker.layout()
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
    /*
    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "预设", style: .plain, target: self, action: #selector(selectColor))
        view.backgroundColor = UIColor.gray
     
        SCLAlertView().showInfo("说明", subTitle: "您可在此选择内置或自定义您的App主题。如果您希望选择预设主题，请点按右上角预设按钮；如果您希望自定义主题，请使用下方的调色盘选择您喜爱的颜色，并按+号确认。", closeButtonTitle: "我知道了" )
    }
    */
    
    
}
