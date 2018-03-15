//
//  TempViewController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 22/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SafariServices
import SCLAlertView

class TempViewController:AbstractViewController {
    
    let provider = SchoolProvider()
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出", style: .plain, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "实名认证", style: .plain, target: self, action: #selector(realname))
    }
    
    @IBAction func download(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main_v2", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"download")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func logout() {
        let alert = SCLAlertView()
        alert.addButton("确认") {
            self.oauth2.oauth2.forgetTokens()
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
            self.navigationController?.popViewController(animated: true)
        }
        alert.showInfo("退出", subTitle: "您确认要退出吗？", closeButtonTitle: "取消")
    }
    
    @IBAction func gallery(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main_v2", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"gallery")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func realname() {
        let safari = SFSafariViewController(url: URL(string : "https://nfls.io/#/alumni/auth")!)
        self.present(safari,animated: true)
    }
    
}
