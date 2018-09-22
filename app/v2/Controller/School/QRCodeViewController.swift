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
        self.provider.getCard { (code) in
            if let code = code {
                self.token = self.getToken(code)
            } else {
                self.token = nil
            }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: self.periodUpdate(_:))
            self.periodUpdate(self.timer)
            NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: .main) { notification in
                //notification.
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.brightness = UIScreen.main.brightness
        UIScreen.main.brightness = 1.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIScreen.main.brightness = self.brightness
    }
    
    private func periodUpdate(_ timer: Timer) {
        if let token = self.token {
            let text = String(Defaults[.id]) + " " + token.currentPassword!
            let data = text.data(using: .ascii)
            let filter = CIFilter(name: "CICode128BarcodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            self.imageview.image = UIImage(ciImage: (filter?.outputImage)!)
        }
    }
    
    private func getToken(_ code: String) -> Token {
        
        guard let secretData = MF_Base32Codec.data(fromBase32String: code), !secretData.isEmpty else {
            fatalError("Invalid secret")
        }
        
        guard let generator = Generator(
            factor: .timer(period: 15),
            secret: secretData,
            algorithm: .sha1,
            digits: 8) else {
                fatalError("Invalid generator parameters")
        }
        
        let token = Token(name: self.realname, issuer: issuer, generator: generator)
        return token
    }
}
