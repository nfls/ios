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
import UserNotifications

class TempViewController:AbstractViewController {
    
    let provider = DeviceProvider()
    let userProvider = UserProvider()
    
    @IBOutlet weak var mdView: MarkdownView!
    
    override func viewDidLoad() {
        mdView.load(markdown: self.provider.announcement)
        self.provider.getAnnouncement(completion: {
            self.mdView.load(markdown: self.provider.announcement)
        })
        self.userProvider.getUser()
        self.provider.checkUpdate { status in
            if status {
                DispatchQueue.main.async {
                let updateDialog = SCLAlertView()
                    updateDialog.addButton("进入App Store更新", action: {
                        let urlStr = "itms-apps://itunes.apple.com/app/id1246252649"
                        UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                    })
                    updateDialog.showNotice("检测到更新", subTitle: "请尽快完成更新，享受更多新特性。", closeButtonTitle: "我懒")
                }
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            DispatchQueue.main.async {
                let pushDialog = SCLAlertView()
                if setting.authorizationStatus == .notDetermined {
                    pushDialog.addButton("好") {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { (_, _) in }
                    }
                    pushDialog.showInfo("推送权限", subTitle: "开启推送后，您可以收到最新的活动通知等。", closeButtonTitle: "不好")
                }else if setting.authorizationStatus == .denied {
                    pushDialog.addButton("设置", action: {
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                    })
                    pushDialog.showWarning("推送权限", subTitle: "设备注册失败，推送未启用", closeButtonTitle: "关闭")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController!.navigationItem.hidesBackButton = true
        self.tabBarController!.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "更多", style: .plain, target: self, action: #selector(menu))
    }
    
    
    @objc func menu() {
        let alert = SCLAlertView()
        alert.addButton("实名") {
            let safari = SFSafariViewController(url: URL(string : "https://nfls.io/#/alumni/auth")!)
            self.present(safari,animated: true)
        }
        alert.addButton("安全") {
            let safari = SFSafariViewController(url: URL(string : "https://nfls.io/#/user/security")!)
            self.present(safari,animated: true)
        }
        alert.addButton("直播") {
            self.live()
        }
        alert.addButton("网页版") {
            UIApplication.shared.open(URL(string: "https://nfls.io")!)
        }
        alert.addButton("退出") {
            self.logout()
        }
        alert.showInfo("更多", subTitle: "部分操作可能需要重新登录", closeButtonTitle: "关闭")
    }
    
    func live() {
        let view = SCLAlertView()
        let code = view.addTextField("直播码")
        code.autocorrectionType = .no
        code.autocapitalizationType = .none
        view.addButton("进入") {
            self.performSegue(withIdentifier: "showLive", sender: code.text)
        }
        view.showInfo("观看直播", subTitle: "请输入直播码", closeButtonTitle: "取消")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! LivePlayerController
        destination.id = sender as? String
    }
    
}
