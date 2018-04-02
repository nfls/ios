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
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出", style: .plain, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "实名认证", style: .plain, target: self, action: #selector(realname))
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToAnnouncement))
        let drag = UIPanGestureRecognizer(target: self, action: #selector(goToAnnouncement))
        
        mdView.isScrollEnabled = false
        mdView.layer.borderWidth = 1.0
        mdView.layer.borderColor = UIColor.gray.cgColor
        mdView.layer.cornerRadius = 10.0
        mdView.load(markdown: self.provider.announcement)
        self.provider.getAnnouncement(completion: {
            self.mdView.load(markdown: self.provider.announcement)
            print(self.provider.announcement)
            self.performSegue(withIdentifier: "showAnnouncement", sender: self)
        })
        tap.delegate = self
        drag.delegate = self
        mdView.subviews[0].addGestureRecognizer(tap)
        mdView.subviews[0].addGestureRecognizer(drag)
        self.provider.checkUpdate { status in
            if status {
                MessageNotifier.showUpdate()
            }
        }
    }
    @objc func goToAnnouncement() {
        if navigationController?.topViewController is AnnouncementViewController {
            return
        }
        self.performSegue(withIdentifier: "showAnnouncement", sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAnnouncement" {
            let dc = segue.destination as! AnnouncementViewController
            dc.text = self.provider.announcement
        }
    }
}

extension TempViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
