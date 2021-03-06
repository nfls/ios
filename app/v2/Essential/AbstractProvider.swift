//
//  Provider.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import Cache
import Result
import ObjectMapper

class AbstractProvider<T:TargetType> {
    let provider:MoyaProvider<T>
    public let notifier:MessageNotifier
    
    init() {
        provider = MainOAuth2().getRequestClosure(type: T.self)
        notifier = MessageNotifier()
    }
    
    internal func request<R:BaseMappable>(
        target: T,
        type: R.Type,
        success successCallback: @escaping (AbstractResponse<R>) -> Void,
        error errorCallback: ((_ error: Error) -> Void)? = nil,
        failure failureCallback: (() -> Void)? = nil
        ) {
        provider.request(target) { (result) in
            switch result {
            case let .success(response):
                if response.statusCode == 400 {
                    if target.baseURL.absoluteString.hasPrefix("https://nfls.io") {
                        NotificationCenter.default.post(name: NSNotification.Name(NotificationType.logout.rawValue), object: nil)
                        self.notifier.showInfo("请重新登录。")
                    } 
                } else {
                    if let json = JSON(response.data).dictionaryObject {
                        do {
                            let value = try AbstractResponse<R>(JSON: json)
                            successCallback(value)
                        } catch let error {
                            debugPrint(error)
                            do {
                                let detail = try AbstractMessage(JSON: json)
                                if let errorCallback = errorCallback {
                                    errorCallback(detail)
                                } else {
                                    self.notifier.showNetworkError(detail)
                                }
                            } catch let errorWithError {
                                debugPrint(errorWithError)
                                if let errorCallback = errorCallback {
                                    errorCallback(AbstractError(status: 1001,message: errorWithError.localizedDescription))
                                } else {
                                    self.notifier.showNetworkError(AbstractError(status: 1001,message: errorWithError.localizedDescription))
                                }
                            }
                        }
                    } else {
                        debugPrint(String(data: response.data, encoding: .utf8) ?? "")
                        if let failureCallback = failureCallback {
                            failureCallback()
                        } else {
                            self.notifier.showNetworkError(AbstractError(status: 1002, message: "JSON解析失败，请检查网络及当前用户权限。"))
                        }
                    }
                }
                
            case .failure(let error):
                debugPrint(error)
                if let failureCallback = failureCallback {
                    failureCallback()
                } else {
                    self.notifier.showNetworkError(AbstractError(status: 0, message: "请求失败"))
                }
            }
        }
    }
}
