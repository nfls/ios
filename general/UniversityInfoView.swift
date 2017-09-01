//
//  UniversityInfoView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/8/31.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import CountryPicker
import Alamofire

class UniversityInfoViewController:UIViewController,CountryPickerDelegate{
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var shortName: UITextField!
    @IBOutlet weak var chineseName: UITextField!
    @IBOutlet weak var chineseShortName: UITextField!
    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var country: CountryPicker!
    @IBOutlet weak var added_by: UITextField!
    @IBOutlet weak var barbutton: UIBarButtonItem!
    var id = 0
    var action = "edit"
    var countryCode = "CN"
    
    override func viewDidAppear(_ animated: Bool) {
        let locale = Locale.current
        countryCode = ((locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?)!
        country.countryPickerDelegate = self
        country.showPhoneNumbers = false
        country.setCountry(countryCode)
        disableFields()
        if(id == 0 && action == "edit"){
            loadMessage()
        } else {
            reloadData()
        }
        
    }
    
    func loadMessage(_ loadMore:Bool = true){
        let headers: HTTPHeaders = [
            "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("https://api.nfls.io/university/intro", method: .get, headers: headers).responseJSON(completionHandler: {
            response in
            switch(response.result){
            case .success(let json):
                let info = ((json as! [String:Any])["info"] as! String).replacingOccurrences(of: "<br/>", with: "\n")
                let notice = UIAlertController(title: "填写提示", message: info, preferredStyle: .alert)
                (notice.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[1] as! UILabel).textAlignment = .left
                let ok = UIAlertAction(title: "我知道了", style: .default, handler: {
                    action in
                    if(loadMore){
                        self.reloadData()
                    }
                })
                notice.addAction(ok)
                self.present(notice, animated: true)
                break
            default:
                break
            }
        })
    }
    @IBAction func showMenu(_ sender: Any) {
        let menu = UIAlertController(title: "操作", message: "新建学校前请先进入查询学校模块", preferredStyle: .actionSheet)
        let query = UIAlertAction(title: "查询学校", style: .default, handler: {
            action in
            self.performSegue(withIdentifier: "showTableSelect", sender: "university")
        })
        let save = UIAlertAction(title: "保存数据", style: .default, handler: {
            action in
            self.saveData()
        })
        let showNotice = UIAlertAction(title: "显示提示", style: .default, handler:{
            action in
            self.loadMessage(false)
        })
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        menu.addAction(query)
        menu.addAction(save)
        menu.addAction(showNotice)
        menu.addAction(cancel)
        menu.popoverPresentationController?.barButtonItem = barbutton
        self.present(menu, animated: true)
    }
    func disableFields(){
        name.isEnabled = false
        shortName.isEnabled = false
        chineseName.isEnabled = false
        chineseShortName.isEnabled = false
        comment.isEnabled = false
    }
    func enableFields(){
        name.isEnabled = true
        shortName.isEnabled = true
        chineseName.isEnabled = true
        chineseShortName.isEnabled = true
        comment.isEnabled = true
    }
    
    func saveData(){
        var passed = true
        if(name.text == "" || shortName.text == "" || name.text == nil || shortName.text == nil){
            passed = false
        }
        if(countryCode != "CN" && (chineseName.text == "" || chineseShortName.text == "" || chineseName.text == nil || chineseShortName.text == nil)){
            passed = false
        }
        if(!passed){
            let alert = UIAlertController(title: "提示", message: "您的信息还未填写完整，请检查！", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true)
        } else {
            let parameters:Parameters = [
                "id": id,
                "name": name.text ?? "",
                "shortName": shortName.text ?? "",
                "chineseName": chineseName.text ?? "",
                "chinsesShortName": chineseShortName.text ?? "",
                "comment": comment.text ?? "",
                "country": countryCode
            ]
            let headers: HTTPHeaders = [
                "Cookie" : "token=" + UserDefaults.standard.string(forKey: "token")!
            ]
            disableFields()
            Alamofire.request("https://api.nfls.io/university/"+action, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:headers).responseJSON { response in
                switch(response.result){
                case .success(let json):
                    if(self.action == "add"){
                        let info = ((json as! [String:AnyObject])["info"] as! [String:Any])
                        self.id = info["id"] as! Int
                        self.action = "edit"
                    }
                    self.reloadData()
                    break
                default:
                    break
                }
            }
        }
    }
    
    func reloadData(){
        //print(id)
        if(action == "add"){
            self.name.text = ""
            self.shortName.text = ""
            self.chineseName.text = ""
            self.chineseShortName.text = ""
            self.comment.text = ""
            self.added_by.text = ""
            self.added_by.isEnabled = false
            self.country.setCountry("US")
            self.enableFields()
        }else if(id == 0){
            self.performSegue(withIdentifier: "showTableSelect", sender: "university")
        } else {
            if(action == "edit"){
                let parameters:Parameters = [
                    "id":id
                ]
                
                Alamofire.request("https://api.nfls.io/university/get", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    switch(response.result){
                    case .success(let json):
                        self.enableFields()
                        let info = ((json as! [String:AnyObject])["info"] as! [String:Any])
                        self.name.text = info["name"] as? String
                        self.shortName.text = info["shortName"] as? String
                        self.chineseName.text = info["chineseName"] as? String
                        self.chineseShortName.text = info["chineseShortName"] as? String
                        self.comment.text = info["comment"] as? String
                        self.added_by.text = info["added_by"] as? String
                        self.added_by.isEnabled = false
                        self.country.setCountry(info["country"] as! String)
                        break
                    default:
                        self.enableFields()
                        break
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showTableSelect" {
            if let destinationVC = segue.destination as? TableSelectViewController {
                destinationVC.type = sender as! String
            }
        }
    }

    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.countryCode  = countryCode
        if(countryCode == "CN"){
            chineseShortName.placeholder = "不需要填写"
            chineseName.placeholder = "不需要填写"
            chineseName.isEnabled = false
            chineseShortName.isEnabled = false
        } else {
            chineseShortName.placeholder = "必填"
            chineseName.placeholder = "必填"
            chineseName.isEnabled = true
            chineseShortName.isEnabled = true

        }
    }
    
    @IBAction func backToUniversityView(segue: UIStoryboardSegue){
        
    }

}
 
