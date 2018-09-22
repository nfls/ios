//
//  UserRequest.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/8/18.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import Moya

enum UserRequest {
    case register(username: String, password: String, code:String, email: String?, phone: String?)
    case reset(password: String, code:String, email: String?, phone: String?)
    case change(password: String, newPassword: String?, newEmail: String?, unbindPhone: Bool?, newPhone: String?, phoneCode: String?, emailCode: String?, clean: Bool?)
    case code(captcha: String, type: Int, email: String?, phone: String?)
    case avatar(image: UIImage)
    case rename(username: String)
    case privacy(antiSpider: Bool, privacy: Int)
    case page(user: Int)
    case current()
    case card()
}

extension UserRequest: TargetType {
    var baseURL: URL {
        return MainConstant.apiEndpoint.appendingPathComponent("user")
    }
    
    var path: String {
        return String(describing: self)
    }
    
    var method: Moya.Method {
        switch self {
        case .register(_, _, _, _, _), .reset(_, _, _, _), .change(_, _, _, _, _, _, _, _), .code(_, _, _, _), .avatar(_), .rename(_), .privacy(_, _):
            return .post
        case .page(_), .current(), .card():
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .register(let username, let password, let code, let email, let phone):
            var parameters = [
                "username": username,
                "password": password,
                "code": code
            ]
            parameters["email"] = email
            parameters["phone"] = phone
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .reset(let password, let code, let email, let phone):
            var parameters = [
                "password": password,
                "code": code
            ]
            parameters["email"] = email
            parameters["phone"] = phone
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .code(let captcha, let type, let email, let phone):
            var parameters: [String: Any] = [
                "captcha": captcha,
                "type": type
            ]
            parameters["email"] = email
            parameters["phone"] = phone
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .change(let password, let newPassword, let newEmail, let unbindPhone, let newPhone, let phoneCode, let emailCode, let clean):
            var parameters: [String: Any] = ["password": password]
            parameters["newPassword"] = newPassword
            parameters["newEmail"] = newEmail
            parameters["unbindPhone"] = unbindPhone
            parameters["newPhone"] = newPhone
            parameters["phoneCode"] = phoneCode
            parameters["emailCode"] = emailCode
            parameters["clean"] = clean
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .avatar(let image):
            let data = image.pngData()!
            let avatar = MultipartFormData(provider: .data(data), name: "photo", fileName: "avatar.png", mimeType: "image/png")
            return .uploadMultipart([avatar])
        case .rename(let username):
            return .requestParameters(parameters: ["username": username], encoding: JSONEncoding.default)
        case .privacy(let antiSpider, let privacy):
            return .requestParameters(parameters: ["antiSpider": antiSpider, "privacy": privacy], encoding: JSONEncoding.default)
        case .page(let user):
            return .requestParameters(parameters: ["id": user], encoding: JSONEncoding.default)
        case .current(), .card():
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    
}
