//
//  GeneralInfoView.swift
//  
//
//  Created by 胡清阳 on 07/06/2017.
//
//

import Foundation
import UIKit
import Alamofire

class GeneralInfoView:UIViewController{
    
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var join_time: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var avator_path: UITextField!
    @IBOutlet weak var is_activated: UISwitch!
    @IBOutlet weak var loadingBar: UIActivityIndicatorView!
     
    override func viewDidLoad() {
        getGeneralInformation()
        
    }
    
    func getGeneralInformation() {
        let headers: HTTPHeaders = [
        "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/generalInfo", headers: headers).responseJSON{ response in
            switch response.result{
            case .success(let json):
                if(((json as! [String:AnyObject])["code"] as! Int)==200){
                    let jsonDic = (json as! [String:AnyObject])["info"]!
                    self.id.text = jsonDic.object(forKey: "id") as? String
                    self.id.isEnabled = false
                    self.join_time.text = jsonDic.object(forKey: "join_time") as? String
                    self.join_time.isEnabled = false
                    self.username.text = jsonDic.object(forKey: "username") as? String
                    self.username.isEnabled = false
                    self.email.text = jsonDic.object(forKey: "email") as? String
                    self.email.isEnabled = false
                    self.avator_path.text = jsonDic.object(forKey: "avatar_path") as? String
                    self.avator_path.isEnabled = false
                    if(jsonDic.object(forKey: "is_activated") as! Int == 1){
                        self.is_activated.setOn(true , animated: true)
                    }
                    self.is_activated.isEnabled = false
                    self.loadingBar.isHidden = true
                }
            default:
                break
            }
        }
    }
    

}
