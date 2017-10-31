//
//  PickerView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/11/1.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import ChromaColorPicker

class PickerViewController:UIViewController,ChromaColorPickerDelegate{
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        dump(color)
    }
    
    
    @IBOutlet weak var container: UIView!
    override func viewDidLoad() {
        let picker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        picker.delegate = self
        picker.padding = 5
        picker.stroke = 3
        container.addSubview(picker)
    }
}
