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
import MarkdownView
import QuartzCore

class TempViewController:AbstractViewController {
    
    let provider = DeviceProvider()
    
    @IBOutlet weak var mdView: MarkdownView!
    
    override func viewDidLoad() {
        mdView.load(markdown: self.provider.announcement)
        self.provider.getAnnouncement(completion: {
            self.mdView.load(markdown: self.provider.announcement)
        })
        self.provider.checkUpdate { status in
            if status {
                MessageNotifier.showUpdate()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController!.navigationItem.hidesBackButton = true
        self.tabBarController!.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出", style: .plain, target: self, action: #selector(logout))
        self.tabBarController!.navigationItem.rightBarButtonItems = []
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
    
    @objc func realname() {
        let controller = SFSafariViewController(url: URL(string: "https://nfls.io/")!)
        self.present(controller, animated: true)
    }
    
}
