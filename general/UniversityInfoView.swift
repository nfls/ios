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
    
    override func viewDidAppear(_ animated: Bool) {
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
        country.countryPickerDelegate = self
        country.showPhoneNumbers = false
        country.setCountry(code!)
        reloadData()
    }
    
    @IBAction func showMenu(_ sender: Any) {
        let menu = UIAlertController(title: "操作", message: nil, preferredStyle: .actionSheet)
        let query = UIAlertAction(title: "查询学校", style: .default, handler: {
            action in
            self.performSegue(withIdentifier: "showTableSelect", sender: "university")
        })
        let save = UIAlertAction(title: "保存数据", style: .default, handler: {
            action in
            
        })
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        menu.addAction(query)
        menu.addAction(save)
        menu.addAction(cancel)
        menu.popoverPresentationController?.barButtonItem = barbutton
        self.present(menu, animated: true)
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
        print(countryCode)
    }
    
    @IBAction func backToUniversityView(segue: UIStoryboardSegue){
        
    }

}
 
