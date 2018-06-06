//
//  Comment.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

struct Comment:ImmutableMappable {
    init(map: Map) throws {
        self.id = try map.value("id")
        self.content = try map.value("content")
        self.time = ISO8601DateFormatter().date(from: try map.value("time"))!
        self.postUser = try map.value("postUser")
    }
    
    let id:Int
    let content:String
    let time:Date
    let postUser:User
    
}
