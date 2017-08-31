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
    var id = 0
    override func viewDidAppear(_ animated: Bool) {
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
        country.countryPickerDelegate = self
        country.showPhoneNumbers = false
        country.setCountry(code!)
        reloadData()
    }
    
    func reloadData(){
        print(id)
        if(id == 0){
            self.performSegue(withIdentifier: "showTableSelect", sender: "university")
        } else {
            let parameters:Parameters = [
                "id":id
            ]
            
            Alamofire.request("https://api.nfls.io/get", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                switch(response.result){
                case .success(let json):
                    break
                default:
                    break
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
 
