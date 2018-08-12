//
//  Constant.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SwiftMessages

class Constant {
    static let mainApiEndpoint: URL = URL(string: "https://nfls.io/")!
    static let waterApiEndpoint: URL = URL(string: "https://water.nfls.io")!
    static let client_id = "9J/xuPUoNBOmA1erNKlBqQ=="
    static let client_secret = "REGbItx41b4IYcK3PiPTXsWTh9KIA0vcHl/W4ediSEg="
}

extension Data {
    var hexString: String {
        return withUnsafeBytes {(bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: count)
            return buffer.map {String(format: "%02hhx", $0)}.reduce("", { $0 + $1 })
        }
    }
}
