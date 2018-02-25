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

class Network<T:TargetType, O> {
    let provider:MoyaProvider<T>
    
    init() {
        provider = NFLSOAuth2().getRequestClosure(type: T.self)
    }
    
    public func request(
        target: T,
        success successCallback: @escaping (JSON) -> Void,
        error errorCallback: @escaping (_ statusCode: Int) -> Void,
        failure failureCallback: @escaping (MoyaError) -> Void
        ) {
            provider.request(target) { (result) in
            switch result {
            case let .success(response):
                do {
                    //try response.filterSuccessfulStatusCodes()
                    let json = try JSON(response.mapJSON())
                    successCallback(json)
                }
                
                catch let error {
                    //errorCallback(error)
                }
                
            case let .failure(error):
                break
                /*
                if target.shouldRetry {
                    retryWhenReachable(target, successCallback, errorCallback, failureCallback)
                }
                else {
                    failureCallback(error)
                }
                */
            }
        }
    }
}

class AbstractProvider<T:TargetType> {
    let provider:MoyaProvider<T>
    let cache:Storage
    
    private func decode<I>(_ response: Result<Moya.Response, MoyaError>? = nil){
    }
    init() {
        provider = NFLSOAuth2().getRequestClosure(type: T.self)
        let diskCache = DiskConfig(name: String(describing: T.self))
        let memoryCache = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
        cache = try! Storage(diskConfig: diskCache, memoryConfig: memoryCache)
    }
}
