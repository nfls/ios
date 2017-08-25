//
//  ViewController.swift
//  general
//
//  Created by 胡清阳 on 17/2/3.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var captchaImage: UIImageView!
    @IBOutlet weak var loadingBar: UIActivityIndicatorView!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var recoverButton: UIButton!
    @IBOutlet weak var captcha: UITextField!
    var session = ""
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.login_button.isEnabled = false;
        self.registerButton.isEnabled = false;
        self.recoverButton.isEnabled = false;
        login_button.addTarget(self,action:#selector(login),for:.touchUpInside)
        if(UserDefaults.standard.value(forKey: "token") != nil){
            self.performSegue(withIdentifier: "ShowHomePage", sender: self)
        }
        requestCaptcha()

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(Button:UIButton){
        self.login_button.isEnabled=false
        self.loadingBar.isHidden=false
        username.resignFirstResponder()
        password.resignFirstResponder()
        let post_data=["username":username.text!,"password":password.text!,"captcha":captcha.text!,"session":session]
        self.LoginAction(post_data: post_data )
    
        
    }
    
    func requestCaptcha(){
        self.loadingBar.isHidden = false
        Alamofire.request("https://api.nfls.io/center/loginCaptcha").responseJSON(completionHandler: {
            response in
            switch(response.result){
            case .success(let json):
                let webStatus = (json as! [String:AnyObject])["code"] as! Int
                if (webStatus == 200){
                    let status = (json as! [String:AnyObject])["info"] as! [String:AnyObject]
                    let captcha = status["captcha"] as! String
                    let session = status["session"] as! String
                    self.session = session
                    self.login_button.isEnabled = true
                    self.recoverButton.isEnabled = true
                    self.registerButton.isEnabled = true
                    self.loadingBar.isHidden = true;
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

    
    @IBAction func returnLogin(segue: UIStoryboardSegue){
        
    }
    
    func LoginAction(post_data:[String: String]=[String: String]()) {
        let parameters = post_data as Parameters
        Alamofire.request("https://api.nfls.io/center/login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {
            response in
            switch(response.result){
            case .success(let json):
                if((json as! [String:AnyObject])["code"] as? Int != 200){
                    self.networkError()
                } else {
                    let webStatus = (json as! [String:AnyObject])["code"] as! Int
                    if (webStatus == 200){
                        let status = (json as! [String:AnyObject])["info"] as! [String:AnyObject]
                        if(status["status"] as! String == "success"){
                            let token = status["token"]! as! String
                            UserDefaults.standard.set(self.username.text!, forKey: "username")
                            UserDefaults.standard.set(self.password.text!, forKey: "password")
                            UserDefaults.standard.set(token, forKey: "token")
                            UserDefaults.standard.synchronize()
                            self.performSegue(withIdentifier: "ShowHomePage", sender: self)
                        } else {
                            let alert = UIAlertController(title: "登陆失败", message: "登陆失败！原因：" + (status["message"] as! String), preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(ok)
                            self.present(alert,animated: true)
                            self.requestCaptcha()
                            self.captcha.text = ""
                        }
                    } else {
                        self.networkError()
                    }
                }
                self.login_button.isEnabled = true
                self.loadingBar.isHidden = true;
                break
            default:
                self.networkError()
                
                break
            }
        })
        
    }
    
    func networkError(){
        let alert = UIAlertController(title: "错误", message: "服务器或网络故障，请检查您的网络连接。", preferredStyle: .alert)
        let ok = UIAlertAction(title: "好的", style: .default, handler: nil)
        let tips = UIAlertAction(title: "TIPS", style: .cancel, handler: {
            action in
            UIApplication.shared.openURL(NSURL(string: "https://zhuanlan.zhihu.com/p/22738261")! as URL)
        })
        alert.addAction(ok)
        alert.addAction(tips)
        self.present(alert,animated: true)
        self.login_button.isEnabled = true
        self.recoverButton.isEnabled = true
        self.registerButton.isEnabled = true
        self.loadingBar.isHidden = true;
    }
}
