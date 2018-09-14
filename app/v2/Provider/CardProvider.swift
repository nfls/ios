//
//  CardProvidewr.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/8.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class CardProvider: AbstractProvider<UserRequest> {
    public func getCard(_ completion: @escaping (String?) -> Void) {
        if(Defaults[.cardSecret] != "") {
            completion(Defaults[.cardSecret])
        } else {
            completion(nil)
        }
        self.request(target: UserRequest.card(), type: Card.self, success: { (data) in
            Defaults[.cardSecret] = data.data.code
            completion(data.data.code)
        }, error: {(_) in
            Defaults[.cardSecret] = ""
            MessageNotifier().showInfo("您的账户没有启用出门证功能")
            completion(nil)
        })
    }
}
