//
//  AlumniRoot.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/9/9.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import SwiftIconFont

class AlumniRootViewController:UITabBarController{
    var in_url = ""
    override func viewDidLoad() {
        for controller in self.viewControllers!{
            if(controller is AlumniActivityViewController){
                controller.tabBarItem!.icon(from: .FontAwesome, code: "plug", iconColor: .black, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
                controller.tabBarItem!.selectedImage = controller.tabBarItem!.image
            } else if(controller is UserCertificationView){
                controller.tabBarItem!.icon(from: .FontAwesome, code: "vcard", iconColor: .black, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            }else if(controller is UniversityInfoViewController){
                controller.tabBarItem!.icon(from: .FontAwesome, code: "university", iconColor: .black, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            }else if(controller is ClubInfoViewController){
                controller.tabBarItem!.icon(from: .FontAwesome, code: "group", iconColor: .black, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            }
        }
    }
    
}
