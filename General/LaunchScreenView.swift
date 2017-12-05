//
//  LaunchScreenView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/8/18.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class LaunchScreenViewController:UIViewController{
    override func viewDidLoad(){
        getImage()
    }
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var text: UILabel!
    var lastView = UIViewController()
    var continued = false
    
    @IBAction func skip(_ sender: Any) {
        nextStep()
    }
    func nextStep(){
        if(!continued){
             let appdelegate = UIApplication.shared.delegate as! AppDelegate
            continued = true
            if(!appdelegate.isLaunched){
                DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                    self.performSegue(withIdentifier: "jumpToLogin",sender:self)
                    appdelegate.isLaunched = true
                })
                
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getImage()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        return
    }
    func loadPic(_ con:Bool = false){
        if let url = UserDefaults.standard.value(forKey: "pic_url") as? String{
            image.kf.setImage(with: URL(string: url)!, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (_, _, _, _) in
                if let image = self.image.image{
                    if(image.size.width == image.size.height){
                        self.image.contentMode = .scaleAspectFit
                    }else{
                        self.image.contentMode = .scaleAspectFill
                    }
                }else{
                    self.image.contentMode = .scaleAspectFill
                }
                if(con){
                    self.nextStep()
                }
            })
            text.text = (UserDefaults.standard.value(forKey: "pic_text") as? String)?.replacingOccurrences(of: "<br/>", with: "\n")
            text.numberOfLines = 0
            text.lineBreakMode = .byWordWrapping
            text.sizeToFit()
        }else{
            if(con){
                self.nextStep()
            }
        }
    }
    func getImage(){
        loadPic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.loadPic(true)
        }
        if(NetworkReachabilityManager()?.isReachable)!{
            if(UserDefaults.standard.string(forKey: "token") == nil){
                return
            }
            let headers: HTTPHeaders = [
                "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
            ]
            Alamofire.request("https://api.nfls.io/device/pics", headers: headers).responseJSON(completionHandler: {
                response in
                switch response.result{
                case .success(let json):
                    if let info = ((json as! [String:AnyObject])["info"]) as? [String:Any] {
                        if(((UserDefaults.standard.value(forKey: "pic_id") as? Int) == nil) || (UserDefaults.standard.value(forKey: "pic_id") as? Int)! < (info["id"] as! Int)){
                            UserDefaults.standard.set(info["url"] as! String, forKey: "pic_url")
                            let text = info["text"] as! String
                            UserDefaults.standard.set(text, forKey: "pic_text")
                            UserDefaults.standard.set((info["id"] as! Int), forKey: "pic_id")
                        }
                    }
                    self.loadPic(true)
                    break
                default:
                    self.loadPic(true)
                    break
                }
            })
        }else{
            loadPic(true)
        }
    }
}
