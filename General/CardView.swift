//
//  CardView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/12/30.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import EFQRCode
import OneTimePassword
import EZSwiftExtensions
import Base32
import CoreImage
import Alamofire

class CardViewController:UIViewController{
    
    @IBOutlet weak var barcode: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var process: UIProgressView!
    
    
    var token:Token? = nil
    var name = "x8ah"
    var chnName = "张三"
    let issuer = "NFLS.IO Internet Authority"
    var secretString = "ou6snqn2ryg77hwfuy2jgowhg2xn7ult"
    var oldPassword = ""
    var lastTime = Date()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        getData()
    }
    
    func getData(){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/ic/card", headers: headers).responseJSON { response in
            switch(response.result){
            case .success(let json):
                let data = (json as! [String:AnyObject])["info"]! as! [String:String]
                self.secretString = data["code"]!
                self.name = data["identifier"]!
                self.chnName = data["name"]!
                self.title = "出门证 - " + self.chnName
            default:
                
                break
            }
            self.token = self.getToken()
            self.updateCode()
        }
    }
    
    func getToken() -> Token? {
        guard let secretData = MF_Base32Codec.data(fromBase32String: secretString),
            !secretData.isEmpty else {
                print("Invalid secret")
                return nil
        }
        guard let generator = Generator(
            factor: .timer(period: 30),
            secret: secretData,
            algorithm: .sha512,
            digits: 8) else {
                print("Invalid generator parameters")
                return nil
        }
        let token = Token(name: name, issuer: issuer, generator: generator)
        return token
    }
    
    
    func updateCode(){
        let password = name + (token!.currentPassword!)
        if(password == oldPassword){
            let elapsed = Date().timeIntervalSince(self.lastTime)
            //ela
            self.process.setProgress((Float(elapsed)/30.0), animated: true)
        }else{
            self.lastTime = Date()
            oldPassword = password
            if let image = EFQRCode.generate(content: password) {
                self.imageView.image = UIImage(cgImage: image)
            }
            self.barcode.image = Barcode.fromString(string: password)
            self.process.setProgress(0, animated: false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.updateCode()
        }
    }
}
class Barcode {
    
    class func fromString(string : String) -> UIImage? {
        
        let data = string.data(using: .ascii)
        let filter = CIFilter(name: "CICode128BarcodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10.0, y: 10.0)
        return UIImage(ciImage: (filter?.outputImage?.transformed(by: transform))!)
    }
    
}

