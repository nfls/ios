//
//  CenterTabRootView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/9/9.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftIconFont

class CenterTabRootViewController:UITabBarController{
    
    @IBOutlet weak var tabbar: UITabBar!
    override func viewDidLoad() {
        for controller in self.viewControllers!{
            if (controller is GeneralInfoView){
                controller.tabBarItem!.icon(from: .FontAwesome, code: "cog", iconColor: .black, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
                controller.tabBarItem!.selectedImage = controller.tabBarItem!.image
            }else if (controller is NotificationViewController){
                controller.tabBarItem!.icon(from: .FontAwesome, code: "inbox", iconColor: .black, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
                let headers: HTTPHeaders = [
                    "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
                ]
                Alamofire.request("https://api.nfls.io/center/count",headers: headers).responseJSON(completionHandler: {
                    response in
                    switch response.result{
                    case .success(let json):
                        if((json as! [String:AnyObject])["code"]! as! Int == 200){
                            controller.tabBarItem!.badgeValue = String(describing: ((json as! [String:Any])["info"] as! Int))
                            if(controller.tabBarItem!.badgeValue == "0"){
                                controller.tabBarItem!.badgeValue = nil
                            }
                        }
                        break
                    default:
                        break
                    }
                })
               
            }else if (controller is AssociatedServiceView){
                controller.tabBarItem!.icon(from: .FontAwesome, code: "key", iconColor: .black, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            }
        }
    }
}
