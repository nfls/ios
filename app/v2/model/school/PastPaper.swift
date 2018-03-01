//
//  pastpaper.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 22/02/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import ObjectMapper

class StsToken:ImmutableMappable {
    let accessKeyId:String
    let accessKeySecret:String
    let securityToken:String
    let expiration:Date
    required init(map: Map) throws {
        self.accessKeyId = try map.value("AccessKeyId")
        self.accessKeySecret = try map.value("AccessKeySecret")
        self.securityToken = try map.value("SecurityToken")
        let exp:String = try map.value("Expiration")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        self.expiration = formatter.date(from: exp)!
    }
}

class File: Codable {
    init(_ object:[String:Any]){
        
        let name = object["Key"] as! String
        if(name.last == "/"){
            self.name = String(name.dropLast())
        }else{
            self.name = name
        }
        
        let range = self.name.range(of: "/", options: .backwards)
        if let range = range {
            self.filename = String(self.name[range.upperBound...])
        } else {
            self.filename = self.name
        }
        if let date = object["LastModified"] as? String, let size = object["Size"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .none
            self.date = dateFormatter.date(from: date)
            self.size = numberFormatter.number(from: size)?.doubleValue
        } else {
            self.date = nil
            self.size = nil
        }
    }
    init(specialAction:String, withName name:String)
    {
        self.name = specialAction
        self.filename = name
        self.date = nil
        self.size = nil
    }
    let name:String
    let filename:String
    let date:Date?
    let size:Double?
    
}
