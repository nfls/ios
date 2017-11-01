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
        UserDefaults.standard.setColor(color: color, forKey: "settings.theme.color")
        UserDefaults.standard.set("customize", forKey: "settings.theme")
    }
    
    @IBOutlet weak var container: UIView!
    override func viewDidLoad() {
        view.backgroundColor = UIColor.gray
        container.backgroundColor = UIColor.gray
        let picker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        picker.delegate = self
        picker.padding = 5
        picker.stroke = 3
        if let color = UserDefaults.standard.colorForKey(key: "settings.theme.color"){
            picker.adjustToColor(color)
        }
        //picker.addButton.isHidden = true
        container.addSubview(picker)
    }
    
    
}
