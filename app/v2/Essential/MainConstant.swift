//
//  Constant.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SwiftMessages
import ObjectMapper
import SwiftyUserDefaults

internal protocol Model: ImmutableMappable, Codable {}

class MainConstant {
    static let apiEndpoint: URL = URL(string: "https://nfls.io/")!
    static let client_id = "9J/xuPUoNBOmA1erNKlBqQ=="
    static let client_secret = "REGbItx41b4IYcK3PiPTXsWTh9KIA0vcHl/W4ediSEg="
    static let header: [String: String] = [
        "Client": "iOS"
    ]
}

class WaterConstant {
    static let apiEndpoint: URL = URL(string: "https://water.nfls.io")!
    static let client_id = "9J/xuPUoNBOmA1erNKlBqQ=="
    static let client_secret = "REGbItx41b4IYcK3PiPTXsWTh9KIA0vcHl/W4ediSEg="
    static let header: [String: String] = [
        "Cookie": "remember_token=" + Defaults[.waterAuthToken].addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    ]
}

extension Data {
    var hexString: String {
        return withUnsafeBytes {(bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: count)
            return buffer.map {String(format: "%02hhx", $0)}.reduce("", { $0 + $1 })
        }
    }
}

extension Date
{
    
    func dateAt(hours: Int, minutes: Int) -> Date
    {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        //get the month/day/year componentsfor today's date.
        
        
        var date_components = calendar.components(
            [NSCalendar.Unit.year,
             NSCalendar.Unit.month,
             NSCalendar.Unit.day],
            from: self)
        
        //Create an NSDate for the specified time today.
        date_components.hour = hours
        date_components.minute = minutes
        date_components.second = 0
        
        let newDate = calendar.date(from: date_components)!
        return newDate
    }
}
