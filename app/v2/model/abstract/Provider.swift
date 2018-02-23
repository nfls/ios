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

class AbstractProvider<T:TargetType> {
    let provider:MoyaProvider<T>
    let cache:Storage
    init() {
        provider = NFLSOAuth2().getRequestClosure(type: T.self)
        let diskCache = DiskConfig(name: String(describing: T.self))
        let memoryCache = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
        cache = try! Storage(diskConfig: diskCache, memoryConfig: memoryCache)
    }
}
