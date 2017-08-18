//
//  UserCertification.swift
//  NFLSers-iOS
//
//  Created by 胡清阳 on 08/06/2017.
//  Copyright © 2017 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class UserCertificationView:UIViewController{
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var enterButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.status.numberOfLines = 0;
        enterButton.isEnabled = false
        checkVersion()
    }
    
    func checkVersion(){
        let parameters:Parameters = [
            "version":Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        ]
        print(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)
        Alamofire.request("https://api.nfls.io/device/auth", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {
            response in
            //dump(response)
            switch(response.result){
            case .success(let json):
                let code = (json as! [String:Int])["code"]
                //print(code)
                if(code == 200){
                    self.getGeneralInformation()
                } else {
                    let alert = UIAlertController(title: "错误", message: "联网检测本地认证数据库版本失败！请尝试将App升级至最新版本后再试。", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "好的", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true)
                }
            default:
                break
            }
            
        })
    }
    
    func getGeneralInformation() {
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/alumni/auth/status", headers: headers).responseJSON(completionHandler: {
            response in
            switch(response.result){
            case .success(let json):
                if((json as! [String:AnyObject])["code"] as! Int == 200){
                    self.enterButton.isEnabled = true
                    let messages = (json as! [String:AnyObject])["message"] as! [String]
                    for message in messages{
                        DispatchQueue.main.async {
                            self.status.text = self.status.text! + message as String! + "\n"
                        }
                    }
                }
            default:
                break
                
            }
        })
        
    }
    
    @IBAction func backToAlumni(segue: UIStoryboardSegue){
        
    }

}
