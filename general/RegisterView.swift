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
    @IBOutlet weak var captcha: UITextField!

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var captcahImage: UIImageView!
    
    var session = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.isEnabled = false
        //iconImage.image = UIImage(named: "logo-NFLS.png")
        
        requestCaptcha()
        
    }
    
    func requestCaptcha(){
        self.activity.isHidden = false
        Alamofire.request("https://api.nfls.io/center/registerCaptcha").responseJSON(completionHandler: {
            response in
            switch(response.result){
            case .success(let json):
                let webStatus = (json as! [String:AnyObject])["code"] as! Int
                if (webStatus == 200){
                    let status = (json as! [String:AnyObject])["info"] as! [String:AnyObject]
                    let captcha = status["captcha"] as! String
                    let session = status["session"] as! String
                    self.session = session
                    self.registerButton.isEnabled = true
                    self.activity.isHidden = true
                    do{
                        try self.captcahImage.image = UIImage(data: Data(contentsOf: URL(string: captcha)!))
                    } catch {
                        self.networkError()
                    }
                }
            default:
                self.networkError()
                break
            }
        })
    }
    @IBAction func register(_ sender: Any){
        backButton.isEnabled = false
        registerButton.isEnabled = false
        activity.isHidden = false
        username.resignFirstResponder()
        password.resignFirstResponder()
        repassword.resignFirstResponder()
        email.resignFirstResponder()
        if(password.text != repassword.text){
            let alert = UIAlertController(title: "错误", message: "两次密码输入不匹配。", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert,animated: true)
            self.backButton.isEnabled = true
            self.registerButton.isEnabled = true
            self.activity.isHidden = true
        } else {
            let parameters: Parameters = [
                "username" : username.text ?? "",
                "password" : password.text ?? "",
                "email" : email.text ?? "",
                "captcha" : captcha.text ?? "",
                "session" : session
            ]
            Alamofire.request("https://api.nfls.io/center/register", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {
                response in
                switch(response.result){
                case .success(let json):
                    let webStatus = (json as! [String:AnyObject])["code"] as! Int
                    if (webStatus == 200){
                        let status = (json as! [String:AnyObject])["info"] as! [String:AnyObject]
                        if(status["status"] as! String == "success"){
                            let alert = UIAlertController(title: "注册成功", message: "注册成功！请在您的邮箱中检查认证邮件。", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(ok)
                            self.present(alert,animated: true)
                        } else {
                            let alert = UIAlertController(title: "注册失败", message: "注册失败！原因：" + (status["message"] as! String), preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(ok)
                            self.present(alert,animated: true)
                            self.requestCaptcha()
                            self.captcha.text = ""
                        }
                        //success / failure
                    } else {
                        self.networkError()                    }
                    break
                default:
                    self.networkError()
                    break
                }
                DispatchQueue.main.async {
                    self.backButton.isEnabled = true
                    self.registerButton.isEnabled = true
                    self.activity.isHidden = true
                }
                
            })
        }
        

    }
    
    func networkError(){
        let alert = UIAlertController(title: "错误", message: "服务器或网络故障，请检查网络连接是否正常，或是否在设置中给予了本程序相关互联网访问权限（仅国行iPhone）。", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
}

