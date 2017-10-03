//
//  WikiView.swift
//  NFLSers-iOS
//
//  Created by 胡清阳 on 17/2/9.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class ICNewsViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var stackView: UIStackView!
    var requestCookies = ""
    var webview = WKWebView()
    var in_url = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let rightButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(previousPage))
        rightButton.icon(from: .FontAwesome, code: "reply", ofSize: 20)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getToken()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func previousPage() {
        webview.goBack()
        webview.reload()
    }
    
    
    func getToken(){
        let cookies:String = "token=" + UserDefaults.standard.string(forKey: "token")!
        let jsCookies = "document.cookie=\"" + cookies + "\"";
        self.requestCookies = cookies
        let cookieScript = WKUserScript(source: jsCookies, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        let webviewConfig = WKWebViewConfiguration()
        let webviewController = WKUserContentController()
        webviewController.addUserScript(cookieScript)
        webviewConfig.userContentController = webviewController
        self.webview = WKWebView(frame: UIScreen.main.bounds ,configuration: webviewConfig)
        self.startRequest(cookies: cookies)
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
    
    func startRequest(cookies:String){
        webview.navigationDelegate = self
        webview.tag = 1
        let url = NSURL(string: "https://ic.nfls.io/"+in_url)!
        let request = NSMutableURLRequest(url: url as URL)
        request.addValue(cookies, forHTTPHeaderField: "Cookie")
        requestCookies = cookies
        webview.load(request as URLRequest)
        stackView.addArrangedSubview(webview)
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = webView.url?.absoluteString
        let realUrl = webView.url!
        if(!url!.hasPrefix("https://ic.nfls.io")){
            webView.stopLoading()
            //webView.goBack()
            if(url!.contains("nfls.io")){
                (navigationController?.viewControllers[navigationController!.viewControllers.count - 2] as! HomeScreenController).handleUrl = url!
                navigationController?.popViewController(animated: true)
            }else{
                let alertController = UIAlertController(title: "外部链接转跳提示",
                                                        message: "您即将以系统浏览器访问该链接："+url!, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
                    action in
                    
                })
                let okAction = UIAlertAction(title: "好的", style: .default, handler: {
                    action in
                    UIApplication.shared.openURL(realUrl)
                })
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
    func networkError(){
        let alert = UIAlertController(title: "错误", message: "服务器或网络故障，请检查网络连接是否正常。", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
    
}
