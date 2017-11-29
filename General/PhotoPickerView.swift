//
//  PhotoPickerView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/11/29.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import SCLAlertView
class PhotoViewController:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    @objc func tapped(){
        let alert = SCLAlertView()
        alert.addButton("拍照") {
            self.takePhotos()
        }
        alert.addButton("相册") {
            self.choosePhotos()
        }
        alert.showInfo("操作", subTitle: "请选择您要识别的照片", closeButtonTitle: "取消")
    }
    func takePhotos() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [kUTTypeImage as String]
        picker.delegate = self
        self.present(picker,animated: true)
    }
    func choosePhotos() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeImage as String]
        picker.delegate = self
        self.present(picker,animated: true)
    }
}
