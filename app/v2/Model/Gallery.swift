//
//  Gallery.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

struct Gallery:ImmutableMappable {
    init(map: Map) throws {
        self.comments = try map.value("comments")
        self.description = try map.value("description")
        self.photos = try map.value("photos")
        self.public = try map.value("public")
        self.time = ISO8601DateFormatter().date(from: try map.value("time"))!
        self.title = try map.value("title")
        self.visible = try map.value("visible")
        self.id = try map.value("id")
    }
    let comments:[Comment]
    let description:String
    let photos:[Photo]
    let `public`:Bool
    let time:Date
    let title:String
    let visible:Bool
    let id:Int
}
