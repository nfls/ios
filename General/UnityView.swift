//
//  UnityView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/12/18.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit

class UnityViewController:UIViewController {
    var unityView: UIView?
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.startUnity()
        
        unityView = UnityGetGLView()!
        
        self.view!.addSubview(unityView!)
        unityView!.translatesAutoresizingMaskIntoConstraints = false
        
        // look, non-full screen unity content!
        let views = ["view": unityView]
        let w = NSLayoutConstraint.constraints(withVisualFormat: "|-20-[view]-20-|", options: [], metrics: nil, views: views)
        let h = NSLayoutConstraint.constraints(withVisualFormat: "V:|-75-[view]-50-|", options: [], metrics: nil, views: views)
        view.addConstraints(w + h)
    }
}
