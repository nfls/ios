//
//  AlumniActivityView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/8/18.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import WebKit

class AlumniActivityViewController:UIViewController,WKNavigationDelegate{
    
    @IBOutlet weak var stackView: UIStackView!
    
    var webview = WKWebView()
    var requestCookies = ""
    var restrcited = false
    override func viewDidLoad() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(self.presentingViewController is UITabBarController){
            restrcited = true
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
        var url = NSURL()
        if(restrcited){
            //url = NSURL(string: "https://forum.nfls.io/settings")!
        } else {
            url = NSURL(string: "https://alumni.nfls.io")!
        }
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
        if(!url!.hasPrefix("https://alumni.nfls.io")){
            webView.stopLoading()
            //webView.goBack()
            if(url!.hasPrefix("https://nfls.io/quickaction.php?action=logout")){
                let alertController = UIAlertController(title: "错误",
                                                        message:"请使用APP内置的退出按钮！" ,preferredStyle: .alert)
                let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else if(url!.hasPrefix("https://nfls.io")){
                self.performSegue(withIdentifier: "back", sender: self)
            } else {
                let alertController = UIAlertController(title: "外部链接转跳提示",
                                                        message: "您即将以系统浏览器访问该链接："+url!, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
                    action in
                    
                })
                let okAction = UIAlertAction(title: "好的", style: .default, handler: {
                    action in
                    UIApplication.shared.openURL(webView.url!)
                })
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func networkError(){
        let alert = UIAlertController(title: "错误", message: "服务器或网络故障，请检查网络连接是否正常。", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }

    
}
