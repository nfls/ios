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
            view.configureContent(title: "错误", body: "网络开小差了:\(error.message)")
        }else{
            view.configureContent(title: "错误", body: "网络开小差了")
        }
        self.show(view)
    }
    public func showInfo(_ info: String) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.info)
        view.configureContent(title: "提示", body: info)
        self.show(view)
    }
}
