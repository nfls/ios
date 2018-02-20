//
//  Constant.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation

class Constant {
    static let photoBaseUrl = "https://nflsio.oss-cn-shanghai.aliyuncs.com/"
    class func getApiUrl() -> String {
        return "https://nfls.io/"
    }
    class func getUrl(string:String?) -> URL? {
        if let string = string {
            return URL(string: self.photoBaseUrl + string)
        } else {
            return nil
        }
    }
    class func getUrl(string:String) -> URL {
        return URL(string: self.photoBaseUrl + string)!
    }
}
