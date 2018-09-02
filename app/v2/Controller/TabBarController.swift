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
        if let tabs = self.tabBar.items {
            dump(tabs)
            tabs[0].icon(from: .materialIcon, code: "info", iconColor: UIColor.blue, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            tabs[1].icon(from: .materialIcon, code: "book", iconColor: UIColor.blue, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            //tabs[2].icon(from: .materialIcon, code: "ballot", iconColor: UIColor.blue, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            tabs[3].icon(from: .materialIcon, code: "web", iconColor: UIColor.blue, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
        }
    }
}
