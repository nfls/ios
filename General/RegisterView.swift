//
//  RegisterView.swift
//  NFLSers-iOS
//
//  Created by 胡清阳 on 07/06/2017.
//  Copyright © 2017 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


class RegisterView:UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repassword: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    
    @IBAction func register(_ sender: Any){
        registerButton.isEnabled = false
        username.resignFirstResponder()
        password.resignFirstResponder()
        repassword.resignFirstResponder()
        email.resignFirstResponder()
        if(password.text != repassword.text){
            let alert = UIAlertController(title: "错误", message: "两次密码输入不匹配。", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert,animated: true)
            self.registerButton.isEnabled = true
        } else {
            
        }
        

    }
    
    func networkError(){
        self.registerButton.isEnabled = true
        let alert = UIAlertController(title: "Error", message: "Network or server error. Please check that you give network permission for this app in Preferences.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
}

