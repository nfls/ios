//
//  TempViewController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 22/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation

class TempViewController:AbstractViewController {
    
    @IBAction func download(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main_v2", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"download")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
   
    @IBAction func gallery(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main_v2", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"gallery")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
