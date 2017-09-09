//
//  ICNewsView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/9/9.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit

class ICNewsViewController:UIViewController{
    override func viewDidAppear(_ animated:Bool){
        let alert = UIAlertController(title: "无新内容", message: "暂时还没有新鲜事哦~请等待10月社团招新以及IB CAS活动的正式开始！", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            self.performSegue(withIdentifier: "close", sender: self)
        }
        alert.addAction(ok)
        self.present(alert,animated: true)
    }
}
