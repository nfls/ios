//
//  SettingView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/10/11.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import InAppSettingsKit

class SettingViewController:IASKAppSettingsViewController,IASKSettingsDelegate{
    func settingsViewControllerDidEnd(_ sender: IASKAppSettingsViewController!) {
        return
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    func settingsViewController(_ sender: IASKAppSettingsViewController!, buttonTappedFor specifier: IASKSpecifier!) {
        print(1)
    }
}
