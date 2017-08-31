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

class UniversityInfoViewController:UIViewController,CountryPickerDelegate{
    @IBOutlet weak var country: CountryPicker!
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
        if(id == 0){
            self.performSegue(withIdentifier: "showTableSelect", sender: "university")
        } else {
            
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

}
 
