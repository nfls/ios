//
//  ICNewsView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/9/9.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Alamofire
import SSZipArchive
import GCDWebServer
import StoreKit
import SCLAlertView
class GameViewController:UIViewController,WKNavigationDelegate,WKUIDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver{
    var names = [String]()
    var ids = [String]()
    var products = [SKProduct]()
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let myProduct = response.products
        print("received!")
        for product in myProduct {
            names.append(product.localizedTitle + " " + product.localizedPrice())
            ids.append(product.productIdentifier)
            products.append(product)
        }
    }
    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
        showCloseButton: false
    ))
    var responder:SCLAlertViewResponder?
    var isProcessing = false
    
    func showLoading(){
        if(!isProcessing){
            isProcessing = true
            responder = alert.showWait("操作中", subTitle: "正在处理您的付款，请保持网络连接畅通！")
        }
    }
    
    func hideLoading(){
        if(isProcessing){
            isProcessing = false
            responder!.close()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch(transaction.transactionState){
            case .purchased:
                
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
                hideLoading()
                break
            case .failed:
                hideLoading()
                SCLAlertView().showError("错误", subTitle: "付款失败，请检查您的App Store账户！")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            default:
                showLoading()
                break
            }
        }
    }
    
    @IBOutlet weak var stackView: UIStackView!
    var requestCookies = ""
    var webview = WKWebView()
    var server = GCDWebServer()
    var in_url = ""
    var location = "fib"
    var name = "Flappy IBO"
    var id = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        server.start(withPort: 6699, bonjourName: "nflsers")
        navigationItem.title = name
        let shop = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(listProducts))
        shop.icon(from: .FontAwesome, code: "ticket", ofSize: 20.0)
        navigationItem.rightBarButtonItem = shop
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        downloadData()
        if(SKPaymentQueue.canMakePayments()) {
            SKPaymentQueue.default().add(self)
            let productID:Set<String> = ["1011","1012","1013","1014"]
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID)
            request.delegate = self
            request.start()
            print("start")
        }else{
            print("error")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        SKPaymentQueue.default().remove(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginLogPageView("Gaming")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        MobClick.endLogPageView("Gaming")
        server.stop()
        super.viewWillDisappear(animated)
    }

    @objc func listProducts(){
        let showProducts = SCLAlertView()
        for (index, _) in ids.enumerated(){
            showProducts.addButton(names[index], action: {
                if SKPaymentQueue.canMakePayments() {
                    let payment = SKPayment(product: self.products[index])
                    SKPaymentQueue.default().add(self)
                    SKPaymentQueue.default().add(payment)
                }
            })
        }
        showProducts.showNotice("购买礼包", subTitle: "请选择以下项目进行购买，款项将用于服务器维护。")
    }
    func downloadData(){
        
        if(NetworkReachabilityManager()!.isReachable){
            let downloading = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
                showCloseButton: false
            ))
            //let downloading = UIAlertController(title: "Resources Updating",
            //                                    message:"Updating resources now, please wait for a while.", preferredStyle: .alert)
            var request:Alamofire.Request?
            //self.present(downloading, animated: true, completion: nil)
            let utilityQueue = DispatchQueue.global(qos: .utility)
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("game.zip")
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            let parameters:Parameters = [
                "version":UserDefaults.standard.string(forKey: location + "_version") ?? "0"
            ]
            if(UserDefaults.standard.string(forKey: location + "_version") != nil){
                downloading.addButton("Offline Mode", action: {
                    request?.cancel()
                    self.getToken(isOnline: false)
                })
            }
            let responder = downloading.showWait("资源更新中", subTitle: "更新资源中，请稍后...")
            request = Alamofire.download("https://game.nfls.io/" + location + "/offline.php", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil, to: destination).downloadProgress(queue: utilityQueue) { progress in
                DispatchQueue.main.async {
                    if(progress.fractionCompleted != 1.0){
                        responder.setSubTitle("更新资源中，请稍后，当前进度 " + String(format: "%.2f", progress.fractionCompleted * 100) + "%")
                    } else {
                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let fileURL = documentsURL.appendingPathComponent("game.zip")
                        let unzipURL = documentsURL.appendingPathComponent(self.location)
                        
                        SSZipArchive.unzipFile(atPath: fileURL.path, toDestination: unzipURL.path)
                        let version = try! String(contentsOf: unzipURL.appendingPathComponent("version.lock"), encoding: String.Encoding.utf8)
                        UserDefaults.standard.set(version, forKey: self.location + "_version")
                        self.updateScore()
                        self.getToken()
                        responder.close()
                    }
                }
                }
                .response { response in
                    downloading.dismiss(animated: true, completion: nil)
                    if let _ = response.error as? AFError {
                        self.getToken(isOnline: false)
                        responder.close()
                    }else{
                        self.getToken()
                        responder.close()
                    }
            }
        } else {
            self.getToken(isOnline: false)
        }

    }
    func updateScore(){
        /*
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        debugPrint(UserDefaults.standard.integer(forKey: "fib_last"))
        Alamofire.request("https://api.nfls.io/center/rank", method: .post, parameters: ["score":UserDefaults.standard.integer(forKey: "fib_last") ], encoding: JSONEncoding.default, headers: headers)
         */
    }
    func getToken(isOnline:Bool = true){
        let cookies:String = "token=" + UserDefaults.standard.string(forKey: "token")!
        let jsCookies = "document.cookie=\"" + cookies + "\";var deviceUsername = 'Offline Mode';var token = '" + UserDefaults.standard.string(forKey: "token")! + "';";
        self.requestCookies = cookies
        let cookieScript = WKUserScript(source: jsCookies, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        let webviewConfig = WKWebViewConfiguration()
        let webviewController = WKUserContentController()
        webviewController.addUserScript(cookieScript)
        webviewConfig.userContentController = webviewController
        self.webview = WKWebView(frame: UIScreen.main.bounds ,configuration: webviewConfig)
        self.startRequest(isOnline: isOnline)
    }
    
    
    func startRequest(isOnline:Bool = true){
        webview.navigationDelegate = self
        webview.uiDelegate = self
        webview.tag = 1
        webview.scrollView.isScrollEnabled = false
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let unzipURL = documentsURL.appendingPathComponent(location)
        debugPrint(unzipURL.path)
        server.addGETHandler(forBasePath: "/", directoryPath: unzipURL.path, indexFilename: "index.html", cacheAge: 0, allowRangeRequests: true)
        var url = NSURL()
        if(isOnline){
            url = NSURL(string: "https://api.nfls.io/redirect?to=http://localhost:6699")!
        }
        else{
            url = NSURL(string: "http://localhost:6699")!
        }
        let request = URLRequest(url: url as URL)
        webview.load(request)
        stackView.addArrangedSubview(webview)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if(navigationAction.request.allHTTPHeaderFields?["Cookie"] == nil){
            decisionHandler(.cancel)
            let request = navigationAction.request as! NSMutableURLRequest
            request.addValue(requestCookies, forHTTPHeaderField: "Cookie")
            webView.load(request as URLRequest)
        } else {
            decisionHandler(.allow)
        }

    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let score = Int(message)!
        if(UserDefaults.standard.integer(forKey: location + "_last") < score){
            UserDefaults.standard.set(score, forKey: location + "_last")
        }
        completionHandler()
    }

    func networkError(){
        let alert = UIAlertController(title: "Error", message: "Network or server error. Please check that you give network permission for this app in Preferences.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
}
extension SKProduct {
    
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
    
}
