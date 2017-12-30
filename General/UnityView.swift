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
    var isRunning = false
    override func viewDidLoad() {
        self.title = "Christmas Carol"
        unityView = UnityGetGLView()!
        self.view.addSubview(unityView!)
        unityView!.translatesAutoresizingMaskIntoConstraints = false
        self.view!.backgroundColor = UIColor.black
        // look, non-full screen unity content!
        let views = ["view": unityView!]
        let w = NSLayoutConstraint.constraints(withVisualFormat: "|-[view]-|", options: [], metrics: nil, views: views)
        let h = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view]-|", options: [], metrics: nil, views: views)
        view.addConstraints(w + h)
        //let res = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reset))
        //self.navigationItem.rightBarButtonItem = res
        
    }
    @objc func reset() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.stopUnity()
        appDelegate.resetUnity()
        appDelegate.startUnity()
    }
    override func viewDidAppear(_ animated: Bool) {
        if isRunning {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.startUnity()
        } else {
            isRunning = true
            let alert = UIAlertController(title: "温馨提醒", message: "此消息将在3秒后自动消失\n1.佩戴耳机获得更佳食用效果\n2.建议在竖屏模式下食用\n3.重置游戏需要后台完全关闭App\n4.如果有任何BUG，请联系游戏开发者谢祖地\nBy:胡清阳", preferredStyle: .alert)
            (alert.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[1] as! UILabel).textAlignment = .left
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                    alert.dismiss(animated: true, completion: {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.startUnity()
                    })
                })
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.stopUnity()
        unityView!.removeFromSuperview()
    }


}
