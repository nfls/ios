//
//  UIAlertProgressViewController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 18/02/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import UIKit

class UIAlertProgressViewController:UIAlertController{
    let progessView = UIProgressView()
    func addProgressView(){
        progessView.setProgress(0.0, animated: true)
        progessView.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
        view.addSubview(progessView)
    }
    func setPercentage(_ percentage:Float){
        DispatchQueue.main.async {
            self.progessView.setProgress(percentage, animated: true)
        }
    }
}
