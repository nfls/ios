//
//  LaunchScreenView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/8/18.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class LaunchScreenViewController:UIViewController{
    override func viewDidLoad(){
        loadPic()
    }
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var text: UILabel!
    var lastView = UIViewController()
    func loadImage(){
        //if(UserDefaults.standard.value(forKey: ""))
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        loadPic()
        getImage()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Thread.sleep(forTimeInterval: 3.0)
        if(!appdelegate.isLaunched){
            performSegue(withIdentifier: "jumpToLogin",sender:self)
            appdelegate.isLaunched = true
        }else{
            //let frame = UIScreen.main.bounds
            self.dismiss(animated: true, completion: nil)
            /*
            appdelegate.window = UIWindow()
            appdelegate.window!.screen = UIScreen.main
            appdelegate.window!.rootViewController = lastView
            //appdelegate.window!.addSubview(lastView.view)
            appdelegate.window!.makeKeyAndVisible()
            */
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return
    }
    func loadPic(){
        var documentsUrl: URL {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        if((UserDefaults.standard.value(forKey: "pic_path") as? String) != nil){
            let fileURL = documentsUrl.appendingPathComponent(UserDefaults.standard.value(forKey: "pic_path") as! String)
            do {
                let imageData = try Data(contentsOf: fileURL)
                self.image.image = UIImage(data: imageData)
            } catch {
                print("Error loading image : \(error)")
            }
            if(image.image!.size.width == image.image!.size.height){
                image.contentMode = .scaleAspectFit
            }else{
                image.contentMode = .scaleAspectFill
            }
            text.text = (UserDefaults.standard.value(forKey: "pic_text") as? String)?.replacingOccurrences(of: "<br/>", with: "\n")
            text.numberOfLines = 0
            text.lineBreakMode = .byWordWrapping
            text.sizeToFit()
        }
    }
    func getImage(){
        if(UserDefaults.standard.string(forKey: "token") == nil){
            return
        }
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        if(UserDefaults.standard.value(forKey: "pic_end") as? Date != nil){
            let date = UserDefaults.standard.value(forKey: "pic_end") as! Date
            let today = Date()
            if(today>date){
                UserDefaults.standard.removeObject(forKey: "pic_path")
                UserDefaults.standard.removeObject(forKey: "pic_text")
                UserDefaults.standard.removeObject(forKey: "pic_end")
                UserDefaults.standard.removeObject(forKey: "pic_id")
            }
        }
        Alamofire.request("https://api.nfls.io/device/pics", headers: headers).responseJSON(completionHandler: {
            response in
            switch response.result{
            case .success(let json):
                let info = ((json as! [String:AnyObject])["info"]) as! [String:Any]
                if(((UserDefaults.standard.value(forKey: "pic_id") as? Int) == nil) || (UserDefaults.standard.value(forKey: "pic_id") as? Int)! < (info["id"] as! Int)){
                    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let fileURL = documentsURL.appendingPathComponent("startup.jpg")
                        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                    }
                    Alamofire.download((info["url"] as! String), to: destination).response { response in
                        if response.error == nil, let imagePath = response.destinationURL?.path {
                            debugPrint("Get a new picture!")
                            UserDefaults.standard.set("startup.jpg", forKey: "pic_path")
                            debugPrint(imagePath)
                            let before = info["invalid_after"] as? String
                            let text = info["text"] as! String
                            UserDefaults.standard.set(text, forKey: "pic_text")
                            let format = DateFormatter()
                            format.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
                            if(before != nil){
                                let date = format.date(from: before! + " GMT+08:00")
                                UserDefaults.standard.set(date, forKey: "pic_end")
                            }
                            UserDefaults.standard.set((info["id"] as! Int), forKey: "pic_id")
                        }
                    }
                }
                break
            default:
                break
            }
        })
    }
}
