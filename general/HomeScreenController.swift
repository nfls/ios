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
        SKPaymentQueue.default().add(self)
        let productID:NSSet = NSSet(object: "2")
        let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start();
    }
    
    @IBAction func closeCurrent(segue: UIStoryboardSegue){
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //vcCount += 1
        navigationItem.title = nil
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
        let cancel = UIAlertAction(title: "返回", style: .cancel, handler: nil)
        dialog.addAction(donate)
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
                Alamofire.request("https://api.nfls.io/device/purchase", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response(completionHandler: { (response) in
                    print(response.response)
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        print("Data: \(utf8Text)")
                    }
                })
                //print(receipt?.base64EncodedData(options: .endLineWithLineFeed))
                //delegate.didBuyColorsCollection(selectedProductIndex)
                
                
            case SKPaymentTransactionState.failed:
                print("Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }

    }
    
    
}
