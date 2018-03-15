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

class Network<T:TargetType> {
    let provider:MoyaProvider<T>
    let cache:Storage
    public let notifier:MessageNotifier
    
    init() {
        provider = NFLSOAuth2().getRequestClosure(type: T.self)
        let diskCache = DiskConfig(name: String(describing: T.self))
        let memoryCache = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
        cache = try! Storage(diskConfig: diskCache, memoryConfig: memoryCache)
        notifier = MessageNotifier()
    }
    
    internal func request<R:ImmutableMappable>(
        target: T,
        type: R.Type,
        success successCallback: @escaping (R) -> Void,
        error errorCallback: ((_ statusCode: Int) -> Void)? = nil,
        failure failureCallback: (() -> Void)? = nil
        ) {
            provider.request(target) { (result) in
            switch result {
            case let .success(response):
                do {
                    if let json = JSON(response.data).dictionaryObject {
                        let value = try AbstractResponse<R>(JSON: json)
                        if(value.code / 100 == 2) {
                            successCallback(value.data!)
                        } else {
                            debugPrint(value)
                            if let errorCallback = errorCallback {
                                errorCallback(value.code)
                            } else {
                                self.notifier.showNetworkError(nil)
                            }
                            
                        }
                    } else {
                        debugPrint("JSON serialization failed.")
                        if let failureCallback = failureCallback {
                            failureCallback()
                        } else {
                            self.notifier.showNetworkError(nil)
                        }
                    }
                }
                catch let error {
                    debugPrint(error)
                    if let failureCallback = failureCallback {
                        failureCallback()
                    } else {
                        self.notifier.showNetworkError(nil)
                    }
                }
            case .failure(let error):
                debugPrint(error)
                if let failureCallback = failureCallback {
                    failureCallback()
                } else {
                    self.notifier.showNetworkError(nil)
                }
            }
        }
    }
}
