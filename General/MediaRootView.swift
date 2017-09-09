//
//  MediaRootView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/9/10.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import SwiftIconFont

class MediaViewController:UITabBarController{
    override func viewDidLoad() {
        for controller in self.viewControllers!{
            if(controller is VideoListViewController){
                controller.tabBarItem!.icon(from: .FontAwesome, code: "film", iconColor: .black, imageSize: CGSize(width:10, height:20), ofSize: 20)
            }else if(controller is LiveListViewController){
                controller.tabBarItem!.icon(from: .FontAwesome, code: "television", iconColor: .black, imageSize: CGSize(width:20, height:20), ofSize: 20)
                controller.tabBarItem!.selectedImage = controller.tabBarItem!.image
            }
        }
    }
}
