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

class ICNewsViewController: UIViewController, WKNavigationDelegate {
 
    var webview = WKWebView()
    
    var requestCookies = ""
    var in_url = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let rightButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(previousPage))
        rightButton.icon(from: .FontAwesome, code: "reply", ofSize: 20)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (navigationController as! NavController).stopFollowingScrollView(showingNavbar: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        self.view.addSubview(webview)
        webview.bindFrameToSuperviewBounds()
        (navigationController as! NavController).followScrollView(webview, delay: 10.0)
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
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = webView.url?.absoluteString
        let realUrl = webView.url!
        if(!url!.hasPrefix("https://ic.nfls.io")){
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
extension UIView {
    
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
}

