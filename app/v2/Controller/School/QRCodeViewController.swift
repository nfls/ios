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

class QRCodeViewController: UIViewController {
    @IBOutlet weak var imageview: UIImageView!
    
    private var realname = "Peter Gu"
    private var issuer = "Leigh Smith"
    private var secret = "JBSWY3DPEHPK3PXP"
    private var token: Token!
    private var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.token = self.getToken()
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: periodUpdate(_:))
        self.periodUpdate(timer)
        NotificationCenter.default.addObserver(forName: .UIApplicationUserDidTakeScreenshot, object: nil, queue: .main) { notification in
            //notification.
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    private func periodUpdate(_ timer: Timer) {
        let text = self.token.currentPassword! + self.realname
        let image = EFQRCode.generate(content: text)
        self.imageview.image = UIImage(cgImage: image!)
    }
    
    private func getToken() -> Token {
        
        guard let secretData = MF_Base32Codec.data(fromBase32String: self.secret), !secretData.isEmpty else {
            fatalError("Invalid secret")
        }
        
        guard let generator = Generator(
            factor: .timer(period: 30),
            secret: secretData,
            algorithm: .sha1,
            digits: 8) else {
                fatalError("Invalid generator parameters")
        }
        
        let token = Token(name: self.realname, issuer: issuer, generator: generator)
        return token
    }
}
