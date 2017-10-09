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

class GameViewController:UIViewController,WKNavigationDelegate,WKUIDelegate{
    @IBOutlet weak var stackView: UIStackView!
    var requestCookies = ""
    var webview = WKWebView()
    var server = GCDWebServer()
    var in_url = ""
    var location = "fib"
    var name = "Flappy IBO"
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        server.start(withPort: 6699, bonjourName: "nflsers")
        navigationItem.title = name
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        downloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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

    
    func downloadData(){
        
        if(NetworkReachabilityManager()!.isReachable){
            let downloading = UIAlertController(title: "Resources Updating",
                                                message:"Updating resources now, please wait for a while.", preferredStyle: .alert)
            var request:Alamofire.Request?
            self.present(downloading, animated: true, completion: nil)
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
                let offlineMode = UIAlertAction(title: "Offline Mode", style: .default, handler: { (action) in
                    request?.cancel()
                    self.getToken(isOnline: false)
                })
                downloading.addAction(offlineMode)
            }
            request = Alamofire.download("https://game.nfls.io/" + location + "/offline.php", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil, to: destination).downloadProgress(queue: utilityQueue) { progress in
                DispatchQueue.main.async {
                    if(progress.fractionCompleted != 1.0){
                        downloading.message = "Updating resources now, please wait for a while. Progress: " + String(format: "%.2f", progress.fractionCompleted * 100) + "%"
                    } else {
                        
                        downloading.dismiss(animated: false, completion: {
                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let fileURL = documentsURL.appendingPathComponent("game.zip")
                            let unzipURL = documentsURL.appendingPathComponent(self.location)
                            
                            SSZipArchive.unzipFile(atPath: fileURL.path, toDestination: unzipURL.path)
                            let version = try! String(contentsOf: unzipURL.appendingPathComponent("version.lock"), encoding: String.Encoding.utf8)
                            UserDefaults.standard.set(version, forKey: self.location + "_version")
                            self.updateScore()
                            self.getToken()
                        })
                    }
                }
                }
                .response { response in
                    downloading.dismiss(animated: true, completion: nil)
                    if let _ = response.error as? AFError {
                        self.getToken(isOnline: false)
                    }else{
                        self.updateScore()
                        self.getToken()
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
