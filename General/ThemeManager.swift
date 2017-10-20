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
        let pink = Theme(style: .black, titleBackgroundColor: UIColor.pantonePMS211(), titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let purple = Theme(style: .black, titleBackgroundColor: UIColor.pantonePMS251(), titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let mintGreen = Theme(style: .black, titleBackgroundColor: UIColor.pantonePMS333(), titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let blueGreen = Theme(style: .black, titleBackgroundColor: UIColor.pantonePMS319(), titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let grass = Theme(style: .black, titleBackgroundColor: UIColor.pantonePMS3395(), titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let fogBlue = Theme(style: .black, titleBackgroundColor: UIColor.pantonePMS297(), titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let killYourEye = Theme(style: .default, titleBackgroundColor: UIColor.green, titleTextColor: UIColor.red, titleButtonColor: UIColor.red)
    }
    var normalTheme:Theme
    var typechoTheme:Theme = ThemeSetting().green
    var gameTheme:Theme = ThemeSetting().black
    init(){
        if let theme = UserDefaults.standard.string(forKey: "settings.theme"){
            switch(theme){
            case "orange":
                normalTheme = ThemeSetting().orange
                break
            case "blue":
                normalTheme = ThemeSetting().blue
                break
            case "green":
                normalTheme = ThemeSetting().green
                break
            case "black":
                normalTheme = ThemeSetting().black
                break
            case "kill":
                normalTheme = ThemeSetting().killYourEye
            case "pink":
                normalTheme = ThemeSetting().pink
            case "purple":
                normalTheme = ThemeSetting().purple
            case "blueGreen":
                normalTheme = ThemeSetting().blueGreen
            case "mintGreen":
                normalTheme = ThemeSetting().mintGreen
            case "grass":
                normalTheme = ThemeSetting().grass
            case "fogBlue":
                normalTheme = ThemeSetting().fogBlue
            default:
                normalTheme = ThemeSetting().pink
                break
            }
        }else{
            normalTheme = ThemeSetting().pink
        }
        if(UserDefaults.standard.bool(forKey: "settings.night.isEnabled")){
            normalTheme = ThemeSetting().black
        }
        if(UserDefaults.standard.bool(forKey: "settings.night.auto")){
            let hour = NSCalendar.current.component(.hour, from: Date())
            if(hour>20 || hour<6){
                normalTheme = ThemeSetting().black
            }
        }
    }
}

