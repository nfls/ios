//
//  StsToken.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/13.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class StsToken:ImmutableMappable {
    let accessKeyId:String
    let accessKeySecret:String
    let securityToken:String
    let expiration:Date
    required init(map: Map) throws {
        self.accessKeyId = try map.value("AccessKeyId")
        self.accessKeySecret = try map.value("AccessKeySecret")
        self.securityToken = try map.value("SecurityToken")
        let exp:String = try map.value("Expiration")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        self.expiration = formatter.date(from: exp)!
    }
}
