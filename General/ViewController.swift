//
//  ViewController.swift
//  general
//
//  Created by 胡清阳 on 17/2/3.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView

class ViewController: UIViewController {
    

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var login_button: UIButton!
    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
        showCloseButton: false
    ))
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.barStyle = .black
        
    }

    @IBAction func returnLogin(segue: UIStoryboardSegue){
        
    }
    
    
}
