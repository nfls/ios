//
//  WKWebViewController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 06/04/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import WebKit

class WKWebViewController: UIViewController {
 
    @IBOutlet weak var stackView: UIStackView?
    
    let webview = WKWebView()
    
    let oauth = MainOAuth2()
    
    var isMain = true
    
    var url: String? = nil
    
    override func viewDidLoad() {
        self.main()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(url)
        UIApplication.shared.isIdleTimerDisabled = false
        if isMain {
            self.tabBarController!.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "FIB", style: .plain, target: self, action: #selector(fib))]
            self.main()
        } else {
            self.tabBarController!.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "主站", style: .plain, target: self, action: #selector(main))]
            self.fib()
        }
    }
    
    @objc func fib() {
        self.webview.load(URLRequest(url: URL(string: "https://nfls.io/game/fib/index.html")!))
        self.tabBarController!.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "主站", style: .plain, target: self, action: #selector(main))]
        self.isMain = false
    }
    
    @objc func main() {
        self.tabBarController!.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "FIB", style: .plain, target: self, action: #selector(fib))]
        self.isMain = true
        oauth.oauth2.authorize { (_, _) in
            var request = URLRequest(url: URL(string: "https://nfls.io/user/fastLogin")!)
            self.stackView!.addArrangedSubview(self.webview)
            try! request.sign(with: self.oauth.oauth2)
            self.webview.load(request)
            self.webview.navigationDelegate = self
        }
    }
}

extension WKWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if let url = url {
            self.url = nil
            webView.load(URLRequest(url: URL(string: "https://nfls.io/#/" + url)!))
        }
    }
}
