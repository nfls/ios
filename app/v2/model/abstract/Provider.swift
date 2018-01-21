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

class AbstractProvider<T:TargetType> {
    let provider:MoyaProvider<T>
    init() {
        provider = NFLSOAuth2().getRequestClosure(type: T.self)
    }
}
