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
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var captchaImage: UIImageView!
    @IBOutlet weak var captcha: UITextField!
    var session = ""
    
    func requestCaptcha(){
        self.activity.isHidden = false
        Alamofire.request("https://api.nfls.io/center/recoverCaptcha").responseJSON(completionHandler: {
            response in
            switch(response.result){
            case .success(let json):
                let webStatus = (json as! [String:AnyObject])["code"] as! Int
                if (webStatus == 200){
                    let status = (json as! [String:AnyObject])["info"] as! [String:AnyObject]
                    let captcha = status["captcha"] as! String
                    let session = status["session"] as! String
                    self.session = session
                    self.send.isEnabled = true
                    self.activity.isHidden = true
                    do{
                        try self.captchaImage.image = UIImage(data: Data(contentsOf: URL(string: captcha)!))
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

    @IBAction func recover(_ sender: Any) {
        activity.isHidden = false
        back.isEnabled = false
        send.isHidden = false
        email.resignFirstResponder()
        let parameters: Parameters = [
            "email" : email.text ?? "",
            "session" : session,
            "captcha" : captcha.text ?? ""
        ]
        Alamofire.request("https://api.nfls.io/center/recover", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {
            response in
            switch(response.result){
            case .success(let json):
                let webStatus = (json as! [String:AnyObject])["code"] as! Int
                if (webStatus == 200){
                    let status = (json as! [String:AnyObject])["info"] as! [String:AnyObject]
                    if(status["status"] as! String == "success"){
                        let alert = UIAlertController(title: "发送成功", message: "请在您的邮箱中检查相关邮件。", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(ok)
                        self.present(alert,animated: true)
                    } else {
                        let alert = UIAlertController(title: "发送失败", message: "原因：" + (status["message"] as! String), preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(ok)
                        self.requestCaptcha()
                        self.present(alert,animated: true)
                    }
                    //success / failure
                } else {
                    self.networkError()
                }
                break
            default:
                self.networkError()
                break
            }
            DispatchQueue.main.async {
                self.back.isEnabled = true
                self.send.isEnabled = true
                self.activity.isHidden = true
            }
            
        })
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        send.isEnabled = false
        requestCaptcha()
    }
    func networkError(){
        let alert = UIAlertController(title: "错误", message: "服务器或网络故障，请检查网络连接是否正常，或是否在设置中给予了本程序相关互联网访问权限（仅国行iPhone）。", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
}
