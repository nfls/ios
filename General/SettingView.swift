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

class SettingViewController:IASKAppSettingsViewController,IASKSettingsDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver{
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
        switch(specifier.key()){
        case "app.license":
            self.performSegue(withIdentifier: "showLicenses", sender: self)
            break
        case "app.user":
            self.performSegue(withIdentifier: "showCenter", sender: self)
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
            self.performSegue(withIdentifier: "showPicker", sender: self)
            break
        default:
            break
        }
    }
    
}
