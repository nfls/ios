//
//  NavigationController.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/10/15.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import AMScrollingNavbar

class NavController:ScrollingNavigationController,UINavigationControllerDelegate,ScrollingNavigationControllerDelegate{
    //let theme = ThemeManager()
    override func viewDidLoad() {
        self.delegate = self
        self.scrollingNavbarDelegate = self
    }
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.scrollingNavbarDelegate = self
        let theme = ThemeManager()
        self.navigationBar.isTranslucent = false
        switch(viewController){
        case is NewsViewController:
            if #available(iOS 11.0, *) {
                self.navigationBar.prefersLargeTitles = true
                
            }
        default:
            if #available(iOS 11.0, *) {
                self.navigationBar.prefersLargeTitles = false
            }
            break
        }
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.foregroundColor: theme.normalTheme.titleButtonColor ?? UIColor.black
            ]
        }
        self.navigationBar.barStyle = theme.normalTheme.style
        self.navigationBar.barTintColor = theme.normalTheme.titleBackgroundColor
        self.navigationBar.tintColor = theme.normalTheme.titleButtonColor
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:theme.normalTheme.titleButtonColor ?? UIColor.black]
    }
    
    func scrollingNavigationController(_ controller: ScrollingNavigationController, willChangeState state: NavigationBarState) {
        let theme = ThemeManager()
        var excution = false
        //dump(controller.viewControllers.last!)
        switch(controller.viewControllers.last!){
        case is ICNewsViewController:
            excution = true
            break
        case is AlumniRootViewController:
            excution = true
            break
        default:
            excution = false
            break
        }
        if(excution){
            switch(state){
            case .collapsed,.scrolling:
                self.navigationBar.barStyle = theme.typechoTheme.style
                self.navigationBar.barTintColor = UIColor(red: 39/255, green: 194/255, blue: 76/255, alpha: 1.0)
                self.navigationBar.tintColor = UIColor(red: 39/255, green: 194/255, blue: 76/255, alpha: 1.0)
                break
            case .expanded:
                self.navigationBar.barStyle = theme.normalTheme.style
                self.navigationBar.barTintColor = theme.normalTheme.titleBackgroundColor
                self.navigationBar.tintColor = theme.normalTheme.titleButtonColor
                break
            }
        }
    }
}
