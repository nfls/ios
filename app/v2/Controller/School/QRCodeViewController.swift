//
//  QRCodeViewController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/6/15.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import OneTimePassword
import Base32
import EFQRCode
import SwiftyUserDefaults

class QRCodeViewController: UIViewController {
    @IBOutlet weak var imageview: UIImageView!
    
    let provider = CardProvider()
    
    private var realname = "Peter Gu"
    private var issuer = "Leigh Smith"
    private var token: Token?
    private var timer: Timer!
    
    private var brightness: CGFloat = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBarController?.navigationItem.rightBarButtonItem = nil
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.brightness = UIScreen.main.brightness
        UIScreen.main.brightness = 1.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIScreen.main.brightness = self.brightness
    }
}
