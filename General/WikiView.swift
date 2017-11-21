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
import SCLAlertView
import AMScrollingNavbar

class WikiViewController: UIViewController, WKNavigationDelegate {
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
        let url = NSURL(string: "https://wiki.nfls.io/"+in_url)!
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
        if(!url!.hasPrefix("https://wiki.nfls.io")){
            webView.stopLoading()
            //webView.goBack()
            if(url!.contains("nfls.io")){
                (navigationController?.viewControllers[navigationController!.viewControllers.count - 2] as! NewsViewController).handleUrl = url!
                navigationController?.popViewController(animated: true)
            }else{
                let alert = SCLAlertView()
                alert.addButton("好的", action: {
                    UIApplication.shared.openURL(realUrl)
                })
                alert.showInfo("外部链接", subTitle: "您即将以系统浏览器访问该外部链接："+url!, closeButtonTitle: "取消")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
