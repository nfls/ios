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
import SCLAlertView

class PickerViewController:UIViewController,ChromaColorPickerDelegate{
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        UserDefaults.standard.setColor(color: color, forKey: "settings.theme.color")
        UserDefaults.standard.set("customize", forKey: "settings.theme")
    }
    
    @IBOutlet weak var container: UIView!
    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "预设", style: .plain, target: self, action: #selector(selectColor))
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
        SCLAlertView().showInfo("说明", subTitle: "您可在此选择内置或自定义您的App主题。如果您希望选择预设主题，请点按右上角预设按钮；如果您希望自定义主题，请使用下方的调色盘选择您喜爱的颜色，并按+号确认。", closeButtonTitle: "我知道了" )
    }
    
    @objc func selectColor(){
        let dialog = SCLAlertView()
        let color:[String:String] = [
            "少女粉":"pink",
            "香芋紫":"purple",
            "蓝绿色":"blueGreen",
            "薄荷绿":"mintGreen",
            "青草绿":"grass",
            "雾霾蓝":"fogBlue",
            "瞎眼睛":"kill"
        ]
        for(key,value)in color{
            dialog.addButton(key, action: {
                UserDefaults.standard.set(value, forKey: "settings.theme")
            })
        }
        dialog.showInfo("预设主题", subTitle: "您可在此选择内置的预设主题", closeButtonTitle: "取消")
    }
    
    
}
