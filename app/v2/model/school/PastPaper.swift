//
//  pastpaper.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 22/02/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class StsToken:ImmutableMappable {
    let accessKeyId:String
    let accessKeyToken:String
    let securityToken:String
    let expiration:Date
    required init(map: Map) throws {
        self.accessKeyId = try map.value("AccessKeyId")
        self.accessKeyToken = try map.value("AccessKeyToken")
        self.securityToken = try map.value("SecurityToken")
        let exp:String = try map.value("Expiration")
        self.expiration = ISO8601DateFormatter().date(from: exp)
    }
}
