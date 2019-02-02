//
//  SearchWebviewController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/10/15.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import WebKit
import SwiftyUserDefaults

class SearchWebviewController: UIViewController {
    @IBOutlet weak var stackview: UIStackView!
    var text: String? = nil
    override func viewDidLoad() {
        if let text = text, let url = URL(string: "https://water.nfls.io/#/search?q="+text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
            let request = URLRequest(url: url)
            let webview = WKWebView()
            self.stackview.addArrangedSubview(webview)
            webview.navigationDelegate = self
            webview.load(request)
        } 
    }
}

extension SearchWebviewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies({ (cookies) in
            //dump(cookies)
            let cookie = cookies.filter({ (cookie) -> Bool in
                return cookie.name == "remember_token"
            })
            if cookie.count == 0 {
                let cookie = HTTPCookie(properties: [
                    HTTPCookiePropertyKey.name : "remember_token",
                    HTTPCookiePropertyKey.path : "/",
                    HTTPCookiePropertyKey.domain : "water.nfls.io",
                    HTTPCookiePropertyKey.value: Defaults[.waterAuthToken]])
                cookieStore.setCookie(cookie!) {
                    webView.load(navigationAction.request)
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
            
            
        })
        
    }
}
