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
            tabs[0].icon(from: .MaterialIcon, code: "info", iconColor: UIColor.blue, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            tabs[1].icon(from: .MaterialIcon, code: "book", iconColor: UIColor.blue, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
            tabs[2].icon(from: .MaterialIcon, code: "web", iconColor: UIColor.blue, imageSize: CGSize(width: 20, height: 20), ofSize: 20)
        }
    }
}
