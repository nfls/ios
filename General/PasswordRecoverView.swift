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
        let parameters: Parameters = [
            "email" : email.text ?? "",
            "session" : "app"
        ]
        Alamofire.request("https://api.nfls.io/center/recover", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {
            response in
            switch(response.result){
            case .success(let json):
                let webStatus = (json as! [String:AnyObject])["code"] as! Int
                if (webStatus == 200){
                    let status = (json as! [String:AnyObject])["info"] as! [String:AnyObject]
                    if(status["status"] as! String == "success"){
                        let alert = UIAlertController(title: "Succeeded", message: "Please check the letter in your email.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(ok)
                        self.present(alert,animated: true)
                    } else {
                        let alert = UIAlertController(title: "Failed", message: "Reason:" + (status["message"] as! String), preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(ok)
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
                self.send.isEnabled = true
            }
            
        })
        
    }

    func networkError(){
        let alert = UIAlertController(title: "Error", message: "Network or server error. Please check that you give network permission for this app in Preferences.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert,animated: true)
        send.isEnabled = true
    }
}
