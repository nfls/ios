//
//  UserCertification.swift
//  NFLSers-iOS
//
//  Created by 胡清阳 on 08/06/2017.
//  Copyright © 2017 胡清阳. All rights reserved.
//

import Foundation
import UIKit

class UserCertificationView:UIViewController{
    @IBOutlet weak var status: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.status.numberOfLines = 0;
        getGeneralInformation()
    }
    
    func getGeneralInformation() {
        DispatchQueue.global().async {
            dump(HTTPCookieStorage.shared.cookies)
            let url:NSURL! = NSURL(string: "https://api.nfls.io/alumni/auth/status")
            let request:NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
            let config = URLSessionConfiguration.ephemeral
            config.httpAdditionalHeaders = ["cookie":"token="+UserDefaults.standard.string(forKey: "token")!]
            let session = URLSession(configuration: config)
            let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                let jsonData:NSDictionary = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                let messages = jsonData.object(forKey: "message") as? [String]
                for message in messages!{
                    DispatchQueue.main.async {
                        self.status.text = self.status.text! + message as String! + "\n"
                    }
                }
            }
            dataTask.resume()
            
            
        }
        
    }
    
    @IBAction func backToAlumni(segue: UIStoryboardSegue){
        
    }

}
