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

class WikiViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var stackView: UIStackView!
    var requestCookies = ""
    var webview = WKWebView()
    override func viewDidLoad() {
        super.viewDidLoad()
        getToken()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func previousPage(_ sender: Any) {
        webview.goBack()
        webview.reload()
    }
    
    
    func getToken(){
        var cookies:String = ""
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        //print(10)
        Alamofire.request("https://api.nfls.io/center/wikiLogin",  headers: headers).responseJSON{
            response in
            dump(response)
            switch response.result{
            case .success(let json):
                print(11)
                let webStatus = (json as! [String:AnyObject])["code"]! as! Int
                if(webStatus != 200){
                    let alert = UIAlertController(title: "错误", message: "您没有激活您的百科账号！请转到个人中心-关联服务界面，选择激活您的百科账号！", preferredStyle: .alert)
                    let back = UIAlertAction(title: "返回", style: .default, handler: nil)
                    alert.addAction(back)
                    self.present(alert,animated: true)
                }else{
                    let jsonDic = (json as! [String:AnyObject])["info"]! as! [String]
                    var jsCookies = [HTTPCookie]()
                    for cookie in jsonDic {
                        let range = cookie.range(of: "; ", options:.regularExpression)
                        let endIndex = cookie.distance(from: cookie.startIndex, to: range!.lowerBound)
                        var realCookie = (cookie as NSString).substring(to: endIndex )
                        if(realCookie.range(of: "[\u{4e00}-\u{9fa5}]",options: .regularExpression) != nil){
                            let range = realCookie.range(of: "[\u{4e00}-\u{9fa5}]",options: .regularExpression)
                            let division = realCookie.distance(from: realCookie.startIndex, to: range!.lowerBound)
                            let cookieHead = (realCookie as NSString).substring(to: division)
                            let cookieContent = (realCookie as NSString).substring(from: division)
                            jsCookies.append(HTTPCookie(properties: [
                                HTTPCookiePropertyKey.domain: "wiki.nfls.io",
                                HTTPCookiePropertyKey.path : "/",
                                HTTPCookiePropertyKey.name : (cookieHead as NSString).substring(to: cookieHead.lengthOfBytes(using: .utf8) - 1),
                                HTTPCookiePropertyKey.value: cookieContent.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
                                HTTPCookiePropertyKey.expires: NSDate(timeIntervalSinceNow: TimeInterval(60 * 60 * 24 * 365))
                                ])!)
                            realCookie = cookieHead + cookieContent.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                        }
                        cookies = cookies + realCookie + ";"
                    }
                    let script = self.getJSCookiesString(cookies: jsCookies)
                    let cookieScript = WKUserScript(source: script, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
                    let webviewConfig = WKWebViewConfiguration()
                    let webviewController = WKUserContentController()
                    webviewController.addUserScript(cookieScript)
                    webviewConfig.userContentController = webviewController
                    self.webview = WKWebView(frame: UIScreen.main.bounds ,configuration: webviewConfig)
                    self.startRequest(cookies: cookies)
                    break
                }
            default:
                self.networkError()
                break
            }
        }
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
    
    func startRequest(cookies:String){
        webview.navigationDelegate = self
        webview.tag = 1
        let url = NSURL(string: "https://wiki.nfls.io")
        let request = NSMutableURLRequest(url: url! as URL)
        request.addValue(cookies, forHTTPHeaderField: "Cookie")
        requestCookies = cookies
        webview.load(request as URLRequest)
        stackView.addArrangedSubview(webview)
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = webView.url?.absoluteString
        if(!url!.hasPrefix("https://wiki.nfls.io")){
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
        } else {
        }
    
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func getJSCookiesString(cookies: [HTTPCookie]) -> String {
        var result = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        
        for cookie in cookies {
            result += "document.cookie='\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path); "
            if let date = cookie.expiresDate {
                result += "expires=\(dateFormatter.string(from: date)); "
            }
            if (cookie.isSecure) {
                result += "secure; "
            }
            result += "'; "
        }
        return result
    }
    
    func networkError(){
        let alert = UIAlertController(title: "错误", message: "服务器或网络故障，请检查网络连接是否正常。", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }

}
