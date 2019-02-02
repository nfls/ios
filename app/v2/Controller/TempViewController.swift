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
import SwiftyUserDefaults
import OneTimePassword
import Base32

class TempViewController:AbstractViewController {
    
    let provider = DeviceProvider()
    let userProvider = UserProvider()
    let cardProvider = CardProvider()
    var token: Token? = nil
    
    @IBOutlet weak var mdView: MarkdownView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        self.imageView.isHidden = true
        mdView.load(markdown: self.provider.announcement)
        mdView.onTouchLink = { url in
            let controller = SFSafariViewController(url: url.url!)
            self.present(controller, animated: true, completion: nil)
            return false
        }
        self.provider.getAnnouncement(completion: {
            self.mdView.load(markdown: self.provider.announcement)
        })
        self.userProvider.getUser() {
            
        }
        self.provider.checkUpdate { status in
            if status {
                DispatchQueue.main.async {
                let updateDialog = SCLAlertView()
                    updateDialog.addButton("进入App Store更新", action: {
                        let urlStr = "itms-apps://itunes.apple.com/app/id1246252649"
                        UIApplication.shared.open(URL(string: urlStr)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                    })
                    updateDialog.showNotice("检测到更新", subTitle: "请尽快完成更新，享受更多新特性。", closeButtonTitle: "我懒")
                }
            }
        }
        self.cardProvider.getCard { (code) in
            if let code = code {
                self.token = self.getToken(code)
            } else {
                self.token = nil
            }
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: self.periodUpdate(_:))
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
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                    })
                    pushDialog.showWarning("推送权限", subTitle: "设备注册失败，推送未启用", closeButtonTitle: "关闭")
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController!.navigationItem.hidesBackButton = true
        self.tabBarController!.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "更多", style: .plain, target: self, action: #selector(menu))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController!.navigationItem.rightBarButtonItem = nil
    }
    
    
    @objc func menu() {
        let alert = SCLAlertView()
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
            NotificationCenter.default.post(name: NSNotification.Name(NotificationType.logout.rawValue), object: nil)
        }
        alert.showInfo("退出", subTitle: "您确认要退出吗？", closeButtonTitle: "取消")
    }
    
    @objc func realname() {
        let controller = SFSafariViewController(url: URL(string: "https://nfls.io/")!)
        self.present(controller, animated: true)
    }
    
    private func periodUpdate(_ timer: Timer) {
        let now = Date()
        if (now > now.dateAt(hours: 11, minutes: 20) && now < now.dateAt(hours: 12, minutes: 40)) {
            if let token = self.token {
                let text = String(Defaults[.id]) + " " + token.currentPassword!
                let data = text.data(using: .ascii)
                let filter = CIFilter(name: "CICode128BarcodeGenerator")
                filter?.setValue(data, forKey: "inputMessage")
                self.imageView.image = UIImage(ciImage: (filter?.outputImage)!)
                self.imageView.isHidden = false
                return
            }
        }
        self.imageView.isHidden = true
    }
    
    private func getToken(_ code: String) -> Token {
        
        guard let secretData = MF_Base32Codec.data(fromBase32String: code), !secretData.isEmpty else {
            fatalError("Invalid secret")
        }
        
        let generator = Generator(factor: .timer(period: 180), secret: secretData, algorithm: .sha1, digits: 8)
        
        let token = Token(name: "", issuer: "", generator: generator!)
        return token
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! LivePlayerController
        destination.id = sender as? String
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
