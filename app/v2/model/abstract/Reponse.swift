//
//  AbstractReponse.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

struct AbstractResponse<T:ImmutableMappable>:ImmutableMappable {
    init(map: Map) throws {
        self.code = try map.value("code")
        self.data = try map.value("data")
    }
    let code:Int
    let data:[Gallery]
    
}
