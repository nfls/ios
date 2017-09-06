//
//  AsociatedServiceView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/6/20.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class AssociatedServiceView:UIViewController{
    
    @IBAction func operate(_ sender: Any) {
        let action = UIAlertController(title: "操作", message: "您可以在此对您的账户安全进行操作", preferredStyle: .actionSheet)
        let editPassword = UIAlertAction(title: "修改用户名及密码", style: .default) { (action) in
            
        }
        let logoutDevices = UIAlertAction(title: "下线所有登录设备", style: .destructive) { (action) in
            
        }
        let editUsername = UIAlertAction(title: "修改用户名", style: .default) { (action) in
            
        }
        let fa = UIAlertAction(title: "二次认证", style: .default) { (action) in
            
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        action.addAction(editPassword)
        action.addAction(logoutDevices)
        action.addAction(editUsername)
        action.addAction(fa)
        action.addAction(cancel)
        self.present(action, animated: true, completion: nil)
    }
}
