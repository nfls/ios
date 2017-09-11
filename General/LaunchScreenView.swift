//
//  LaunchScreenView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/8/18.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit

class LaunchScreenViewController:UIViewController{
    override func viewDidLoad(){
        loadPic()
    }
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var text: UILabel!
    func loadImage(){
        //if(UserDefaults.standard.value(forKey: ""))
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        Thread.sleep(forTimeInterval: 3.0)
        performSegue(withIdentifier: "jumpToLogin",sender:self)
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
}
