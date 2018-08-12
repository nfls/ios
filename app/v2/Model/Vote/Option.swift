//
//  Option.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/12.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class Option: ImmutableMappable {
    required init(map: Map) throws {
        self.text = try map.value("text")
        self.options = try map.value("options")
    }
    
    let text: String
    let options: [String]
}
