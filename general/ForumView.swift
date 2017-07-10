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

class ForumViewer: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    var webview = WKWebView()
    var requestCookies = ""
    override func viewDidLoad() {
         UIApplication.shared.isNetworkActivityIndicatorVisible = true
        super.viewDidLoad()
        getToken()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func previousPage(_ sender: Any) {
        (stackView.viewWithTag(1) as! WKWebView).goBack()
    }
    
    
    func getToken(){
        var cookies:String = ""
        var jsCookies = ""
        let username = UserDefaults.standard.string(forKey: "username")!
        let password = UserDefaults.standard.string(forKey: "password")!
        let token = UserDefaults.standard.string(forKey: "token")!
        let parameters:Parameters = [
            "username":username,
            "password":password,
            "token":token
        ]
        Alamofire.request("https://api.nfls.io/center/forumLogin", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
            response in
            switch response.result{
            case .success(let json):
                let jsonDic = (json as! [String:AnyObject])["info"]! as! [String]
                for cookie in jsonDic {
                    let range = cookie.range(of: "; ", options:.regularExpression)
                    let endIndex = cookie.distance(from: cookie.startIndex, to: range!.lowerBound)
                    let realCookie = (cookie as NSString).substring(to: endIndex )
                    cookies = cookies + realCookie + ";"
                    jsCookies = "document.cookies='" + cookie + "';"
                }
                self.requestCookies = cookies
                let cookieScript = WKUserScript(source: jsCookies, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
                let webviewConfig = WKWebViewConfiguration()
                let webviewController = WKUserContentController()
                webviewController.addUserScript(cookieScript)
                webviewConfig.userContentController = webviewController
                self.webview = WKWebView(frame: UIScreen.main.bounds ,configuration: webviewConfig)
                self.startRequest(cookies: cookies)
                break
            default:
                self.networkError()
                break
            }
        }
    }
    
    func startRequest(cookies:String){
        webview = WKWebView(frame: UIScreen.main.bounds)
        webview.navigationDelegate = self
        webview.tag = 1
        let url = NSURL(string: "https://forum.nfls.io")
        let request = NSMutableURLRequest(url: url! as URL)
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
        }
        decisionHandler(.allow)
        
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = webView.url?.absoluteString
        if(!url!.hasPrefix("https://forum.nfls.io")){
            webView.stopLoading()
            //webView.goBack()
            if(url!.hasPrefix("https://nfls.io/quickaction.php?action=logout")){
                let alertController = UIAlertController(title: "错误",
                                                        message:"请使用APP内置的退出按钮！" ,preferredStyle: .alert)
                let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else {
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
