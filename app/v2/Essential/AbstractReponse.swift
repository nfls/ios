//
//  AbstractReponse.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import ObjectMapper
import Foundation


struct AbstractResponse<T: BaseMappable>: ImmutableMappable {
    init(map: Map) throws {
        self.code = try map.value("code")
        if(String(describing: T.self).contains("Wrapper")) {
            self.data = T(JSON: map.JSON)!
        } else {
            self.data = try map.value("data")
        }
    }
    let code:Int
    let data:T
}

class DataWrapper<T>: ImmutableMappable {
    required init(map: Map) throws {
        self.value = try map.value("data")
    }
    let value:T
}
