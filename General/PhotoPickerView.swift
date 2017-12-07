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
import Alamofire
import Toucan

class PhotoViewController:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    var originalWidth:CGFloat = 0
    var originalHeight:CGFloat = 0
    var isSubmitted:Bool = false
    struct People{
        var name:String
        var code:String
    }
    struct Class{
        var name:String
        var people:[People]
    }
    var classList = [Class]()
    override func viewDidLoad() {
        view.backgroundColor = UIColor.black
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(upload)),UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(tapped)),UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showList))]
        tapped()
        getName()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let debugPress = UITapGestureRecognizer(target: self, action: #selector(showDebug))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(debugPress)
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        originalWidth = image.size.width
        originalHeight = image.size.height
        isSubmitted = false
        picker.dismiss(animated: true, completion: nil)
    }
    @objc func upload(){
        if(isSubmitted){
            SCLAlertView().showError("错误", subTitle: "此照片已经识别过了", closeButtonTitle: "关闭")
            return
        }
        if let image = imageView.image {
            let progressView = UIProgressController(title: "上传中", message: "正在上传您的照片，请稍后", preferredStyle: .alert)
            progressView.addProgressView()
            self.present(progressView, animated: true)
            let headers: HTTPHeaders = [
                "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
            ]
            Alamofire.upload(multipartFormData: { (data) in
                let resizeImage = Toucan(image: image).resize(CGSize(width: 2000, height: 2000), fitMode: .clip).image!
                DispatchQueue.main.async {
                    self.imageView.image = resizeImage
                }
                let imageData = UIImageJPEGRepresentation(resizeImage, 90.0)!
                data.append(imageData, withName: "file", fileName: "pic.jpg", mimeType: "image/jpeg")
            }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: "https://api.nfls.io/face/upload", method: .post, headers: headers, encodingCompletion: { (result) in
                switch result{
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        progressView.dismiss(animated: true, completion: nil)
                        switch response.result {
                        case .success(let json):
                            if let path = (json as! [String:Any])["info"] as? String{
                                let responder = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false)).showWait("请稍后", subTitle: "正在处理您的请求")
                                self.isSubmitted = true
                                self.fetchResult(path, responder: responder)
                            }else{
                                self.showError()
                            }
                        default:
                            self.showError()
                            break
                        }
                    }
                    upload.uploadProgress { progress in
                        progressView.setPercentage(Float(progress.fractionCompleted))
                    }
                default:
                    break
                }
               
            })
        }else{
            SCLAlertView().showError("错误", subTitle: "请选择一张照片", closeButtonTitle: "关闭")
        }
    }
    func showError(){
        SCLAlertView().showError("错误", subTitle: "网络或服务器错误，请稍候再试", closeButtonTitle: "关闭")
    }
    func fetchResult(_ path:String, responder:SCLAlertViewResponder){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        let parameters:Parameters = [
            "path": path
        ]
        Alamofire.request("https://api.nfls.io/face/check", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch(response.result){
            case .success(let json):
                let code = (json as! [String:AnyObject])["code"] as! Int
                switch code{
                case 1001:
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2.0, execute: {
                        self.fetchResult(path, responder: responder)
                    })
                    break
                case 1002:
                    responder.close()
                    SCLAlertView().showError("错误", subTitle: "没有识别到人脸", closeButtonTitle: "关闭")
                    break
                case 200:
                    responder.close()
                    let infos = (json as! [String:AnyObject])["info"] as! [[String:Any]]
                    
                    for info in infos {
                        let image = self.imageView.image!
                        let name = info["name"] as! String
                        let yAxis = info["y-axis"] as! Int
                        let xAxis = info["x-axis"] as! Int
                        let confidence = info["confidence"] as! Double
                        let label = self.getName(withCode: name) + "(" + String(format: "%.1f", confidence * 100) + "%)"
                        self.imageView.image = self.textToImage(drawText: label, inImage: image, atPoint: CGPoint(x: xAxis, y: yAxis))
                    }
                default:
                    responder.close()
                    self.showError()
                    
                }
            default:
                responder.close()
                self.showError()
            }
            
            
        }
    }
    @objc func showDebug(){
        print("aa")
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
    @objc func showList(){
        
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
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Courier", size: 56)!
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            NSAttributedStringKey.backgroundColor: UIColor.black.withAlphaComponent(0.5)
            ] as [NSAttributedStringKey : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func getName(){
        classList.removeAll()
        Alamofire.request("https://api.nfls.io/storage/_teachers.json").responseJSON { (response) in
            switch(response.result){
            case .success(let res):
                let data = res as! [AnyObject]
                for cla in data {
                    let claz = cla as! [String:AnyObject]
                    var realClass = Class(name: claz["name"] as! String, people: [])
                    let people = claz["people"] as! [[String:String]]
                    for person in people{
                        let p = People(name: person["name"]!, code: person["code"]!)
                        realClass.people.append(p)
                    }
                    self.classList.append(realClass)
                    dump(realClass)
                }
            default:
                break
            }
            
        }
    }
    
    func getName(withCode code:String) -> String{
        for claz in classList{
            for person in claz.people {
                if person.code == code{
                    return person.name
                }
            }
        }
        return code
    }
}
