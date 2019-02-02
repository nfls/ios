//
//  NFLSOauth2.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 18/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import p2_OAuth2
import Alamofire
import Moya

class MainOAuth2 {
    public let oauth2: OAuth2PasswordGrant
    
    init() {
        oauth2 = OAuth2PasswordGrant(settings: [
            "client_id": MainConstant.client_id,
            "client_secret": MainConstant.client_secret,
            "authorize_uri": "http://nfls.io/oauth/authorize",
            "token_uri": "https://nfls.io/oauth/accessToken",
            "scope": "",
            "secret_in_body": true,
            "keychain": true,
            "verbose": true
            ] as OAuth2JSON)
    }
    
    func login(username:String,password:String, completion: @escaping (_ success: Bool, _ water: Bool) -> Void) {
        oauth2.password = password
        oauth2.username = username
        oauth2.authorize { (_, error) in
            if error != nil {
                completion(false, false)
            }else{
                let water = WaterAuth()
                completion(true, false)
                water.login({ (status) in
                    //completion(true, status)
                })
            }
        }
    }
    
    func getRequestClosure<T:TargetType>(type:T.Type) -> MoyaProvider<T> {
        let requestClosure:MoyaProvider<T>.RequestClosure = { (endpoint, done) in
            var request = try! endpoint.urlRequest() // This is the request Moya generates
            self.oauth2.authorize { (_, error) in
                if error != nil {
                    self.oauth2.forgetTokens()
                }
            }
            if request.url!.host! != "nfls.io" {
                done(.success(request))
            } else {
                do {
                    try request.sign(with: self.oauth2)
                    done(.success(request))
                } catch {
                    done(.success(request))
                }
            }
        }
        let provider = MoyaProvider<T>(requestClosure: requestClosure, plugins: [/*NetworkLoggerPlugin(verbose: true)*/])
        return provider
    }
    
}
