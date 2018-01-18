//
//  loginView.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 18/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import OA

class LoginViewController:UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        password.isSecureTextEntry = true
    }
}
