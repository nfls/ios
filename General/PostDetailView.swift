//
//  PostDetailView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/8/18.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import WebKit
class PostDetailViewController:UIViewController{
    var cid:Int = 0
    @IBOutlet weak var stackview: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(cid)
    }
    
}
