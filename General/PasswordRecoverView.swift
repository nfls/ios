//
//  PasswordRecoverView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/7/3.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class PasswordRecoverViewController:UIViewController{
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var send: UIButton!
    

    @IBAction func recover(_ sender: Any) {
        send.isHidden = false
        email.resignFirstResponder()
        
        
    }

    func networkError(){
        let alert = UIAlertController(title: "Error", message: "Network or server error. Please check that you give network permission for this app in Preferences.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true)
        send.isEnabled = true
    }
}
