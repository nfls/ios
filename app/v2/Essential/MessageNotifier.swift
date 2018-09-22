//
//  MessageNotifier.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 01/04/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SwiftMessages

class MessageNotifier {
    private func show(_ view: MessageView) {
        view.configureDropShadow()
        view.button?.isHidden = true
        SwiftMessages.show(view: view)
    }
    public func showNetworkError(_ error: AbstractMessage?) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.error)
        if let error = error {
            view.configureContent(title: "错误", body: "\(error.message)")
        }else{
            view.configureContent(title: "错误", body: "网络跑路了")
        }
        self.show(view)
    }
    public func showInfo(_ info: String) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.info)
        view.configureContent(title: "提示", body: info)
        self.show(view)
    }
    class public func showUpdate() {
        let view = MessageView.viewFromNib(layout: .centeredView)
        view.configureTheme(.info)
        view.configureContent(title: "检测到新版本", body: "新版本已发布，请及时更新以使用最新功能！")
        view.configureDropShadow()
        view.button?.addTarget(self, action: #selector(goToAppStore), for: UIControl.Event.touchDown)
        view.button?.setTitle("进入App Store更新", for: UIControl.State.normal)
        var config = SwiftMessages.defaultConfig
        config.duration = .seconds(seconds: 3)
        SwiftMessages.show(config: config, view: view)
    }
    @objc class func goToAppStore() {
        let urlStr = "itms://itunes.apple.com/app/id1246252649"
        UIApplication.shared.open(URL(string: urlStr)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
