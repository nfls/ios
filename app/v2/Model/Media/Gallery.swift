//
//  Gallery.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Gallery: Model {
    required init(map: Map) throws {
        self.id = try map.value("id")
        self.visible = try map.value("visible")
        self.public = try map.value("public")
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        if let time = formatter.date(from: try map.value("time")) {
            self.time = time
        } else {
            self.time = ISO8601DateFormatter().date(from: try map.value("time"))!
        }
        self.title = try map.value("title")
        self.description = try map.value("description")
        self.originCount = try map.value("originCount")
        self.photoCount = try map.value("photoCount")
        self.photos = try? map.value("photos")
        self.comments = try? map.value("comments")
        self.likes = try? map.value("likes")
        self.cover = try? map.value("cover")
    }
    
    let id: Int
    let visible: Bool
    let `public`: Bool
    let time: Date
    let title: String
    let description: String
    let originCount: Int
    let photoCount: Int
    let cover: Photo?
    let comments: [Comment]?
    let photos: [Photo]?
    let likes: [User]?
}

