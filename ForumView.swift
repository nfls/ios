//
//  ForumView.swift
//  NFLSers-iOS
//
//  Created by 胡清阳 on 17/2/9.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SCLAlertView

class ForumViewer: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    var webview = WKWebView()
    var requestCookies = ""
    var in_url = ""
    override func viewDidLoad() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(self.presentingViewController is UITabBarController){
            in_url = "settings"
        }
        getToken()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func previousPage(_ sender: Any) {
        (stackView.viewWithTag(1) as! WKWebView).goBack()
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
    
    func startRequest(cookies:String){
        webview = WKWebView(frame: UIScreen.main.bounds)
        webview.navigationDelegate = self
        webview.tag = 1
        let url = NSURL(string: ("https://forum.nfls.io/"+in_url))!
        let request = NSMutableURLRequest(url: url as URL)
        request.addValue(cookies, forHTTPHeaderField: "Cookie")
        webview.load(request as URLRequest)
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

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = webView.url?.absoluteString
        let realUrl = webView.url!
        if(!url!.hasPrefix("https://forum.nfls.io")){
            webView.stopLoading()
            if(url!.contains("nfls.io")){
                let nav = self.presentingViewController as! UINavigationController
                (nav.viewControllers.last as! NewsViewController).handleUrl = url!
                self.performSegue(withIdentifier: "back", sender: self)
            } else {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
                    showCloseButton: false
                ))
                alert.addButton("好的", action: {
                    UIApplication.shared.openURL(realUrl)
                })
                alert.showInfo("外部链接", subTitle: "您即将以系统浏览器访问该外部链接："+url!, closeButtonTitle: "取消")
            }
        }
    }
}
