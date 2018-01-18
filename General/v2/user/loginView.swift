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

class LoginViewController:NFLSViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    @IBAction func login(_ sender: Any) {
        oauth2.login(username: username.text!, password: password.text!) { success in
            if(success){
                self.performSegue(withIdentifier: "showDl", sender: self)
            }else{
                SCLAlertView().showError("错误", subTitle: "用户名或密码不正确")
            }
        }
    }
    
    override func viewDidLoad() {
        password.isSecureTextEntry = true
    }
}
