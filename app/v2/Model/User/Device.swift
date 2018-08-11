//
//  Device.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/7/22.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

struct PushDevice: ImmutableMappable {
    init(map: Map) throws {
        self.id = try map.value("id")
        self.token = try map.value("token")
        self.model = try map.value("model")
        self.callbackToken = try map.value("callbackToken")
        self.type = DeviceType(rawValue: try map.value("type"))!
    }
    
    let id: String
    let token: String
    let model: String
    let callbackToken: String
    let type: DeviceType
    
    enum DeviceType: Int {
        case ios = 1
        case we_chat = 2
    }
}
