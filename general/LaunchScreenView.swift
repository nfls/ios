//
//  LaunchScreenView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/8/18.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit

class LaunchScreenViewController:UIViewController{
    override func viewDidLoad(){
        print(1)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        Thread.sleep(forTimeInterval: 3.0)
        performSegue(withIdentifier: "jumpToLogin",sender:self)
        return
    }
}
