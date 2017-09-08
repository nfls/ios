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
    
    @IBOutlet weak var baritem: UIBarButtonItem!
    @IBAction func operate(_ sender: Any) {
        let action = UIAlertController(title: "操作", message: "您可以在此对您的账户安全进行操作", preferredStyle: .actionSheet)
        let editPassword = UIAlertAction(title: "修改邮箱及密码", style: .default) { (action) in
            self.performSegue(withIdentifier: "showEditing", sender: self)
            
        }
        let logoutDevices = UIAlertAction(title: "下线所有登录设备", style: .destructive) { (action) in
            Alamofire.request("https://api.nfls.io/center/regenToken").responseJSON(completionHandler: { (response) in
                switch(response.result){
                case .success( _):
                    self.performSegue(withIdentifier: "goBack", sender: self)
                    break
                default:
                    break
                }
            })
        }
        let editUsername = UIAlertAction(title: "修改用户名", style: .default) { (action) in
            let headers: HTTPHeaders = [
                "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
            ]
            Alamofire.request("https://api.nfls.io/center/card", headers:headers).responseJSON(completionHandler: { (response) in
                switch(response.result){
                case .success(let json):
                    let count = ((json as! [String:AnyObject])["info"] as! [String:Int])["rename_cards"]!
                    let check = UIAlertController(title: "提示", message: "此处您可以修改您的用户名，长度3-16位，支持英文、数字、下划线、中文及日文。您目前拥有 " + String(describing: count) + "张改名卡，本次修改需要消耗1张。关于如何获取改名卡，可访问”关于我们“页面。", preferredStyle: .alert)
                    let back = UIAlertAction(title: "返回", style: .cancel, handler: nil)
                    let change = UIAlertAction(title: "修改", style: .default, handler: {
                        action in
                        let action = UIAlertController(title: "请输入", message: "请输入您的新的用户名，确认后，请至个人信息页面查询是否修改成功，未修改则说明不符合要求或者是与他人重复。", preferredStyle: .alert)
                        action.addTextField(configurationHandler: { (textfield) in
                            textfield.placeholder = "用户名"
                        })
                        let ok = UIAlertAction(title: "确认", style: .default, handler: { (alert) in
                            let parameters:Parameters = [
                                "name": action.textFields![0].text ?? ""
                            ]
                            Alamofire.request("https://api.nfls.io/center/rename", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {_ in })
                        })
                        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                        action.addAction(ok)
                        action.addAction(cancel)
                        self.present(action,animated: true)
                    })
                    check.addAction(back)
                    if(count > 0){
                        check.addAction(change)
                    }
                    self.present(check, animated: true)
                    break
                default:
                    break
                }
            })
        }
        
        let _ = UIAlertAction(title: "二次认证", style: .default) { (action) in
            
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        action.addAction(editPassword)
        action.addAction(logoutDevices)
        action.addAction(editUsername)
        //action.addAction(fa)
        action.addAction(cancel)
        action.popoverPresentationController?.barButtonItem = baritem
        self.present(action, animated: true, completion: nil)
    }
}
