//
//  TempViewController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 22/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation

class TempViewController:AbstractViewController {
    
    let provider = SchoolProvider()
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出", style: .plain, target: self, action: #selector(logout))
    }
    
    @IBAction func download(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main_v2", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"download")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func logout() {
        oauth2.oauth2.forgetTokens()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func gallery(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main_v2", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"gallery")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
