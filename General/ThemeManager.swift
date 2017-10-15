//
//  ThemeManager.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/10/11.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIColor_Pantone

class ThemeManager{
    struct Theme{
        var style:UIBarStyle
        var titleBackgroundColor:UIColor?
        var titleTextColor:UIColor?
        var titleButtonColor:UIColor?
    }
    struct ThemeSetting{
        let orange = Theme(style: .black, titleBackgroundColor: UIColor.pantonePMS1665(), titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let blue = Theme(style: .black, titleBackgroundColor: UIColor.pantonePMS2748(), titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let green = Theme(style: .black , titleBackgroundColor: UIColor(red: 77/255, green: 151/255, blue: 70/255, alpha: 1.0), titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let black = Theme(style: .black, titleBackgroundColor: UIColor.black, titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let killYourEye = Theme(style: .default, titleBackgroundColor: UIColor.green, titleTextColor: UIColor.red, titleButtonColor: UIColor.red)
    }
    var normalTheme:Theme
    var typechoTheme:Theme = ThemeSetting().black
    var gameTheme:Theme = ThemeSetting().black
    init(){
        if let theme = UserDefaults.standard.string(forKey: "settings.theme"){
            switch(theme){
            case "orange":
                normalTheme = ThemeSetting().orange
                typechoTheme = ThemeSetting().black
                break
            case "blue":
                normalTheme = ThemeSetting().blue
                typechoTheme = ThemeSetting().black
                break
            case "green":
                normalTheme = ThemeSetting().green
                typechoTheme = ThemeSetting().green
                break
            case "black":
                normalTheme = ThemeSetting().black
                typechoTheme = ThemeSetting().black
                break
            case "kill":
                normalTheme = ThemeSetting().killYourEye
                typechoTheme = ThemeSetting().killYourEye
            default:
                normalTheme = ThemeSetting().green
                typechoTheme = ThemeSetting().green
                break
            }
        }else{
            normalTheme = ThemeSetting().green
            typechoTheme = ThemeSetting().green
        }
        gameTheme = ThemeSetting().black
        if(UserDefaults.standard.bool(forKey: "settings.night.isEnabled")){
            normalTheme = ThemeSetting().black
            typechoTheme = ThemeSetting().black
            gameTheme = ThemeSetting().black
        }
        if(UserDefaults.standard.bool(forKey: "settings.night.auto")){
            let hour = NSCalendar.current.component(.hour, from: Date())
            if(hour>20 || hour<6){
                normalTheme = ThemeSetting().black
                typechoTheme = ThemeSetting().black
                gameTheme = ThemeSetting().black
            }
        }
    }
}

