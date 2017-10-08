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
    
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.barStyle = .black
        Alamofire.request("https://api.nfls.io/weather/ping")
        let rightButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(settings))
        rightButton.icon(from: .FontAwesome, code: "users", ofSize: 20)
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.title = "Login"
        navigationItem.prompt = "南外人"

    }
    
    @objc func settings(){
        let actions = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let register = UIAlertAction(title: "Register", style: .destructive) { (action) in
            self.performSegue(withIdentifier: "showRegister", sender: self)
        }
        let reset = UIAlertAction(title: "Reset Password", style: .default) { (action) in
            self.performSegue(withIdentifier: "showReset", sender: self)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        actions.addAction(reset)
        actions.addAction(register)
        actions.addAction(cancel)
        self.present(actions, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        login_button.addTarget(self,action:#selector(login),for:.touchUpInside)
        if(UserDefaults.standard.value(forKey: "token") != nil){
            self.performSegue(withIdentifier: "ShowHomePage", sender: self)
        }
        

    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(Button:UIButton){
        username.resignFirstResponder()
        password.resignFirstResponder()
        let post_data=["username":self.username.text!,"password":self.password.text!,"session":"app"]
        LoginAction(post_data: post_data )
    }
    
    
    
    @IBAction func returnLogin(segue: UIStoryboardSegue){
        
    }
    
    func LoginAction(post_data:[String: String]) {

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
                            UserDefaults.standard.set(token, forKey: "token")
                            UserDefaults.standard.synchronize()
                            self.performSegue(withIdentifier: "ShowHomePage", sender: self)
                        } else {
                            let alert = UIAlertController(title: "Failed", message: "Login Failed! Reason:" + (status["message"] as! String), preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(ok)
                            self.present(alert,animated: true)
                        }
                    } else {
                        self.networkError()
                    }
                }
                self.login_button.isEnabled = true
                break
            default:
                self.networkError()
                
                break
            }
        })
        
    }
    
    func networkError(){
        let alert = UIAlertController(title: "Error", message: "Network or server error. Please check that you give network permission for this app in Preferences.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true)
        self.login_button.isEnabled = true
    }
}
