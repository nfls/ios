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
        let orange = Theme(style: .black, titleBackgroundColor: UIColor.pantoneOrange021(), titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let blue = Theme(style: .black, titleBackgroundColor: UIColor.pantonePMS2748(), titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let green = Theme(style: .black , titleBackgroundColor: UIColor.pantonePMS375(), titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let black = Theme(style: .black, titleBackgroundColor: UIColor.black, titleTextColor: UIColor.white, titleButtonColor: UIColor.white)
        let white = Theme(style: .default, titleBackgroundColor: UIColor.white, titleTextColor: UIColor.black, titleButtonColor: UIColor.black)
        let killYourEye = Theme(style: .default, titleBackgroundColor: UIColor.green, titleTextColor: UIColor.red, titleButtonColor: UIColor.red)
    }
    var normalTheme:Theme
    var typechoTheme:Theme = ThemeSetting().white
    var gameTheme:Theme = ThemeSetting().white
    init(){
        if let theme = UserDefaults.standard.string(forKey: "settings.theme"){
            switch(theme){
            case "orange":
                normalTheme = ThemeSetting().orange
                typechoTheme = ThemeSetting().white
                break
            case "blue":
                normalTheme = ThemeSetting().blue
                typechoTheme = ThemeSetting().black
                break
            case "green":
                normalTheme = ThemeSetting().green
                typechoTheme = ThemeSetting().green
                break
            case "white":
                normalTheme = ThemeSetting().white
                typechoTheme = ThemeSetting().white
                break
            case "black":
                normalTheme = ThemeSetting().black
                typechoTheme = ThemeSetting().black
                break
            case "kill":
                normalTheme = ThemeSetting().killYourEye
                typechoTheme = ThemeSetting().killYourEye
            default:
                normalTheme = ThemeSetting().black
                typechoTheme = ThemeSetting().black
                break
            }
        }else{
            normalTheme = ThemeSetting().black
            typechoTheme = ThemeSetting().black
        }
        gameTheme = ThemeSetting().black
        if(UserDefaults.standard.bool(forKey: "settings.night.isEnabled")){
            normalTheme = ThemeSetting().black
            typechoTheme = ThemeSetting().black
            gameTheme = ThemeSetting().black
        }
    }
}

