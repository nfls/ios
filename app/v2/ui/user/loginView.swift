//
//  loginView.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 18/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import p2_OAuth2
import SCLAlertView
import WebKit
import SafariServices

class LoginViewController:AbstractViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var isFirst = true
    
    override func viewDidAppear(_ animated: Bool) {
        //self.login(UIButton())
        self.username.text = UserDefaults.standard.string(forKey: "username")
        self.password.text = UserDefaults.standard.string(forKey: "password")
        if(isFirst){
            self.login(UIButton())
        }
    }
        
    @IBAction func register(_ sender: Any) {
        let safari = SFSafariViewController(url: URL(string : "https://nfls.io/#/user/register")!)
        self.present(safari,animated: true)
    }
    
    @IBAction func reset(_ sender: Any) {
        let safari = SFSafariViewController(url: URL(string : "https://nfls.io/#/user/reset")!)
        self.present(safari,animated: true)
    }
    
    @IBAction func login(_ sender: Any) {
        if(!isFirst){
            oauth2.oauth2.forgetTokens()
        }
        oauth2.login(username: username.text!, password: password.text!) { success in
            if(success){
                let storyboard = UIStoryboard(name: "Main_v2", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier :"temp")
                self.navigationController!.pushViewController(viewController, animated: true)
                UserDefaults.standard.set(self.username.text!, forKey: "username")
                UserDefaults.standard.set(self.password.text!, forKey: "password")
            }else{
                if(!self.isFirst){
                    SCLAlertView().showError("错误", subTitle: "用户名或密码不正确")
                }
            }
            self.isFirst = false
        }
    }
    
    override func viewDidLoad() {
        password.isSecureTextEntry = true
    }
}
