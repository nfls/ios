//
//  WaterOAuth2.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/19.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults

class WaterAuth {
    let notifier = MessageNotifier()
    private let headers: HTTPHeaders = [
        "Client": "iOS"
    ]
    
    func login(_ completion: @escaping (_ success: Bool) -> Void) {
        Alamofire.request(WaterConstant.apiEndpoint.appendingPathComponent("user/login"), headers: self.headers).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let string = json["data"].string, let url = URL(string: string) {
                    self.authorize(url: url, completion: completion)
                } else {
                    self.notifier.showNetworkError(AbstractMessage(status: 0, message: "JSON解析错误"))
                    completion(false)
                }
            case .failure(let error):
                self.notifier.showNetworkError(AbstractMessage(status: 0, message: error.localizedDescription))
                completion(false)
            }
        }
    }
    
    func authorize(url: URL, completion: @escaping (_ success: Bool) -> Void) {
        var request = URLRequest(url: url)
        try! request.sign(with: MainOAuth2().oauth2)
        request.addValue("iOS", forHTTPHeaderField: "Client")
        Alamofire.request(request).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let string = json["data"].string, let url = URL(string: string) {
                    self.final(url: url, completion: completion)
                } else {
                    self.notifier.showNetworkError(AbstractMessage(status: 0, message: "JSON解析错误"))
                    completion(false)
                }
            case .failure(let error):
                self.notifier.showNetworkError(AbstractMessage(status: 0, message: error.localizedDescription))
                completion(false)
            }
        }
    }
    
    func final(url: URL, completion: @escaping (_ success: Bool) -> Void) {
        if url.host == "water.nfls.io" {
            Alamofire.request(url, headers: headers).responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let string = json["data"].string {
                        switch string {
                        case "/#/":
                            Defaults[.waterAuthToken] = json["cookie"]["remember_token"].string ?? ""
                            completion(true)
                            break
                        case "/#/login?reason=permission":
                            self.notifier.showInfo("未实名用户。请尽快在“更多”-“实名”内完成实名认证。")
                            completion(false)
                            break
                        case "/#/login?reason=private":
                            self.notifier.showInfo("该功能目前关闭。")
                            completion(false)
                            break
                        case "/#/login?reason=invalid_state":
                            self.notifier.showInfo("服务器错误。")
                            completion(false)
                            break
                        default:
                            break
                        }
                        
                    } else {
                        self.notifier.showNetworkError(AbstractMessage(status: 0, message: "JSON解析错误"))
                        completion(false)
                    }
                case .failure(let error):
                    self.notifier.showNetworkError(AbstractMessage(status: 0, message: error.localizedDescription))
                    completion(false)
                }
            }
        } else {
            self.notifier.showInfo("App部分功能需要绑定邮箱。同时，根据相关法律法规，国内用户需要绑定手机号，国外用户需要确保实名认证已通过。请尽快在“更多”-“安全”内补齐相关信息。")
            completion(false)
        }
        
    }
}
