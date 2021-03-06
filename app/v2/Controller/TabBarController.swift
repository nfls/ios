//
//  TabBarControlelr.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 06/04/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import SwiftIconFont

class HomeViewController: UITabBarController {
    override func viewDidLoad() {
        //self.delegate = self
        if let tabs = self.tabBar.items {
            //dump(tabs)
            tabs[0].icon(from: .materialIcon, code: "info", iconColor: UIColor.blue, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            tabs[1].icon(from: .materialIcon, code: "pool", iconColor: UIColor.blue, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            tabs[2].icon(from: .materialIcon, code: "photo", iconColor: UIColor.blue, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            //tabs[3].icon(from: .materialIcon, code: "receipt", iconColor: UIColor.blue, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            tabs[3].icon(from: .materialIcon, code: "settings", iconColor: UIColor.blue, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            //
        }
        self.navigationItem.hidesBackButton = true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
}
