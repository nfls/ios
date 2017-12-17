//
//  Extension.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/12/6.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit

class UIProgressController:UIAlertController{
    let progessView = UIProgressView()
    func addProgressView(){
        progessView.setProgress(0.0, animated: true)
        progessView.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
        view.addSubview(progessView)
    }
    func setPercentage(_ percentage:Float){
        progessView.setProgress(percentage, animated: true)
    }
}
