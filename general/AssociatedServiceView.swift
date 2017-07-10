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
    @IBOutlet weak var forumID: UITextField!
    @IBOutlet weak var forumUsername: UITextField!
    @IBOutlet weak var forumNotificationRead: UITextField!
    @IBOutlet weak var forumLastlogin: UITextField!
    @IBOutlet weak var forumThreadCount: UITextField!
    @IBOutlet weak var forumCommentCount: UITextField!
    @IBOutlet weak var wikiUserID: UITextField!
    @IBOutlet weak var wikiUsername: UITextField!
    @IBOutlet weak var wikiRealname: UITextField!
    @IBOutlet weak var wikiRegisterTime: UITextField!
    @IBOutlet weak var wikiLastLogin: UITextField!
    @IBOutlet weak var shareID: UITextField!
    @IBOutlet weak var shareUsername: UITextField!
    @IBOutlet weak var shareRegisterTime: UITextField!
    @IBOutlet weak var shareLastLogin: UITextField!
    @IBOutlet weak var shareLoginIP: UITextField!
    @IBOutlet weak var shareDownloadAmount: UITextField!
    @IBOutlet weak var shareUploadAmount: UITextField!
    @IBOutlet weak var wikiActivateButton: UIButton!
    @IBOutlet weak var shareActivateButton: UIButton!
    override func viewDidLoad() {
        initialize()
    }
    
    func initialize(){
        loadForumData()
        loadWikiData()
        loadShareData()

    }
    
    func loadForumData(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/forumInfo", headers: headers).responseJSON{ response in
            switch response.result{
            case .success(let json):
                if(((json as! [String:AnyObject])["code"] as! Int)==200){
                    let jsonDic = (json as! [String:AnyObject])["info"]!
                    self.updateTextfield(textfield: self.forumID, text: String(jsonDic["id"] as! Int))
                    self.updateTextfield(textfield: self.forumUsername, text: jsonDic["username"] as? String)
                    self.updateTextfield(textfield: self.forumNotificationRead, text: jsonDic["notifications_read_time"] as? String)
                    self.updateTextfield(textfield: self.forumLastlogin, text: jsonDic["last_seen_time"] as? String)
                    self.updateTextfield(textfield: self.forumThreadCount, text: String(jsonDic["discussions_count"] as! Int))
                    self.updateTextfield(textfield: self.forumCommentCount, text: String(jsonDic["comments_count"] as! Int))
                }
                else {
                    self.showAlert(false)
                }
                break
            default:
                self.showAlert(false)
                break
            }
        }
    }
    
    func loadWikiData(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/wikiInfo", headers: headers).responseJSON{ response in
            switch response.result{
            case .success(let json):
                if(((json as! [String:AnyObject])["code"] as! Int)==200){
                    let jsonDic = (json as! [String:AnyObject])["info"]!
                    self.wikiActivateButton.isEnabled = false
                    self.wikiActivateButton.setTitle("已激活", for: UIControlState.normal)
                    self.updateTextfield(textfield: self.wikiUserID, text: String(jsonDic["user_id"] as! Int))
                    self.updateTextfield(textfield: self.wikiRealname, text: jsonDic["user_real_name"] as? String)
                    self.updateTextfield(textfield: self.wikiUsername, text: jsonDic["user_name"] as? String)
                    self.updateTextfield(textfield: self.wikiLastLogin, text: jsonDic["user_touched"] as? String)
                    self.updateTextfield(textfield: self.wikiRegisterTime, text: jsonDic["user_registration"] as? String)
                }
                else {
                    self.updateTextfield(textfield: self.wikiUserID, text: "尚未激活")
                    self.updateTextfield(textfield: self.wikiRealname, text: "尚未激活")
                    self.updateTextfield(textfield: self.wikiUsername, text: "尚未激活")
                    self.updateTextfield(textfield: self.wikiLastLogin, text: "尚未激活")
                    self.updateTextfield(textfield: self.wikiRegisterTime, text: "尚未激活")
                }
                break
            default:
                self.showAlert(false)
                break
            }
        }
    }
    
    
    func loadShareData(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/shareInfo", headers: headers).responseJSON{ response in
            switch response.result{
            case .success(let json):
                if(((json as! [String:AnyObject])["code"] as! Int)==200){
                    let jsonDic = (json as! [String:AnyObject])["info"]!
                    self.shareActivateButton.isEnabled = false
                    self.shareActivateButton.setTitle("已激活", for: UIControlState.normal)
                    self.updateTextfield(textfield: self.shareID, text: String(jsonDic["user_id"] as! Int))
                    self.updateTextfield(textfield: self.shareUsername, text: jsonDic["user_name"] as? String)
                    self.updateTextfield(textfield: self.shareLastLogin, text: jsonDic["user_touched"] as? String)
                    self.updateTextfield(textfield: self.shareRegisterTime, text: jsonDic["user_registration"] as? String)
                    self.updateTextfield(textfield: self.shareLoginIP, text: jsonDic["user_ip"] as? String)
                    self.updateTextfield(textfield: self.shareUploadAmount, text: String(jsonDic["user_uploaded"] as! Int))
                    self.updateTextfield(textfield: self.shareDownloadAmount, text: String(jsonDic["user_downloaded"] as! Int))

                }
                else {
                    self.updateTextfield(textfield: self.shareID, text: "尚未激活")
                    self.updateTextfield(textfield: self.shareUsername, text: "尚未激活")
                    self.updateTextfield(textfield: self.shareLastLogin, text: "尚未激活")
                    self.updateTextfield(textfield: self.shareRegisterTime, text: "尚未激活")
                    self.updateTextfield(textfield: self.shareLoginIP, text: "尚未激活")
                    self.updateTextfield(textfield: self.shareUploadAmount, text: "尚未激活")
                    self.updateTextfield(textfield: self.shareDownloadAmount, text: "尚未激活")
                }
                break
            default:
                self.showAlert(false)
                break
            }
        }
    }
    
    
    @IBAction func activateWiki(_ sender: Any) {
        self.wikiActivateButton.isEnabled = false
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/wikiRegister", headers: headers).responseJSON{ response in
            switch response.result{
            case .success(let json):
                if(((json as! [String:AnyObject])["code"] as! Int)==200){
                    self.initialize()
                }
                else {
                    self.showAlert(true)
                }
                break
            default:
                self.showAlert(false)
                break
            }
        }
    }
    
    
    
    @IBAction func activateShare(_ sender: Any) {
        self.shareActivateButton.isEnabled = false
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/center/shareRegister", headers: headers).responseJSON{ response in
            switch response.result{
            case .success(let json):
                if(((json as! [String:AnyObject])["code"] as! Int)==200){
                    self.initialize()
                }
                else {
                    self.showAlert(true)
                }
                break
            default:
                self.showAlert(false)
                break
            }
        }

    }
    
    func showAlert(_ reload:Bool = false){
        let alertController = UIAlertController(title: "错误",
                                                message: "服务器或网络故障。请检查您的网络连接，或者稍后再试", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        if(reload){
            initialize()
        }
    }
    
    func updateTextfield(textfield:UITextField, text:String?){
        textfield.text = text
        textfield.isEnabled = false
    }
}
