//
//  NavigationController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/21.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SCLAlertView
import SafariServices

class NavigationController: UINavigationController {
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(notAuthorize), name: NSNotification.Name(NotificationType.notAuthorized.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notBind), name: NSNotification.Name(NotificationType.notBind.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: NSNotification.Name(NotificationType.logout.rawValue), object: nil)
    }
    
    @objc func logout() {
        MainOAuth2().oauth2.forgetTokens()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        guard let filePaths = try? fileManager.contentsOfDirectory(at: myDocuments, includingPropertiesForKeys: nil, options: []) else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        for filePath in filePaths {
            try? fileManager.removeItem(at: filePath)
        }
        while(self.viewControllers.count > 1) {
            self.popViewController(animated: true)
        }
    }
    
    @objc func notAuthorize() {
        let alert = SCLAlertView()
        alert.addButton("实名认证") {
            let safari = SFSafariViewController(url: URL(string : "https://nfls.io/#/alumni/auth")!)
            self.present(safari,animated: true)
        }
        alert.showError("错误", subTitle: "实名认证未完成，您请求的功能可能会不可用。", closeButtonTitle: "关闭")
        
    }
    
    @objc func notBind() {
        let alert = SCLAlertView()
        alert.addButton("安全设置") {
            let safari = SFSafariViewController(url: URL(string : "https://nfls.io/#/user/security")!)
            self.present(safari,animated: true)
        }
        alert.showError("错误", subTitle: "邮箱及手机尚未绑定，您请求的功能可能会不可用。", closeButtonTitle: "关闭")
    }
}
