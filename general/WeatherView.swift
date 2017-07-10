//
//  WeatherView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/7/6.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class WeatherViewController:UIViewController{
    override func viewDidAppear(_ animated: Bool) {
        
        let alert = UIAlertController(title: "此区域尚未开放", message: "本服务将于9月1号开学后提供", preferredStyle: .alert)
        let action = UIAlertAction(title: "返回", style: .default, handler: {
            action in
            self.performSegue(withIdentifier: "back", sender: self)
        })
        alert.addAction(action)
        self.present(alert, animated: true)

    }
}
