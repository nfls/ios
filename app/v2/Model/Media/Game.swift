//
//  Game.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/13.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Game: Model {
    required init(map: Map) throws {
        self.id = try map.value("id")
        self.title = try map.value("title")
        self.thumb = try map.value("thumb")
        self.subTitle = try map.value("subTitle")
        self.description = try map.value("description")
        self.preferBigger = try map.value("preferBigger")
        self.contents = try map.value("content")
    }
    
    let id: Int
    let title: String
    let thumb: String
    let subTitle: String
    let description: String
    let preferBigger: Bool
    let contents: [Content]
    
    class Content: Model {
        required init(map: Map) throws {
            self.key = try map.value("key")
            self.name = Name(rawValue: try map.value("name"))!
            self.extra = try? map.value("extra")
        }
        
        let key: String
        let name: Name
        let extra: String?
        
        enum Name: String, Codable {
            case ios = "ios"
            case windows = "windows"
            case mac = "mac"
            case web = "web"
            case android = "android"
        }
    }
}
