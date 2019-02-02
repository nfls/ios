//
//  InternationalCenterController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/23.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import YPImagePicker
import TesseractOCR
import SCLAlertView
import DeviceKit

class InternationalCenterController: UIViewController, G8TesseractDelegate {
    
    @IBOutlet weak var searchStack: UIStackView!
    
    @IBOutlet weak var textField: UITextField!
    let problemProvider = ProblemProvider()
    var shouldCancel = false
    override func viewDidAppear(_ animated: Bool)  {
        if !Device().isPad {
            self.searchStack.isHidden = true
        } else {
            self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(camera))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    @objc func camera() {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.startOnScreen = .library
        config.showsCrop = .none
        //config.showsCrop = .rectangle(ratio: 1.0/1.0)
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { (items, _) in
            picker.dismiss(animated: true)
            if let photo = items.singlePhoto {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                alert.addButton("取消", action: {
                    self.shouldCancel = true
                })
                let response = alert.showWait("请稍后", subTitle: "识别中，最长可能需要1分钟。")
            
                DispatchQueue.global().async {
                    self.shouldCancel = false
                    let ocr = G8Tesseract(language: "eng")
                    ocr?.image = photo.image
                    ocr?.delegate = self
                    ocr?.recognize()
                    DispatchQueue.main.async {
                        
                        if !self.shouldCancel {
                            response.close()
                            self.textField.text = ocr?.recognizedText
                            self.performSegue(withIdentifier: "search", sender: self)
                        }
                    }
                }
            }
            
        }
        self.present(picker, animated: true)
    }
    
    @IBAction func search(_ sender: Any) {
        self.performSegue(withIdentifier: "search", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SearchWebviewController {
            controller.text = textField.text ?? ""
        }
        
    }
    
    func shouldCancelImageRecognition(for tesseract: G8Tesseract!) -> Bool {
        return self.shouldCancel
    }
}
