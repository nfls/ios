//
//  UserRequest.swift
//  NFLSers-iOS
//
//  Created by 胡清阳 on 2018/6/6.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum UserRequest {
    case register(username: String, password: String, email: String?, phone: String?, code: String)
    case reset(email: String?, phone: String?, code: String, password: String)
    case login(username: String, password: String)
    case current()
    case info()
    case change()
    case avatar()
    case rename()
}

extension UserRequest: TargetType {
    
}
