//
//  User.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

struct User:ImmutableMappable {
    init(map: Map) throws {
        self.id = try map.value("id")
        self.username = try map.value("username")
        self.point = try map.value("point")
        self.admin = try map.value("admin")
    }
    let id:Int
    let username:String
    let point:Int
    let admin:Bool
}
